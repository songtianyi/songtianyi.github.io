# amqp rpc 模式实现

## 安装 rabiitmq

#### mac

``` 

brew install rabbitmq
rabbitmq-server -detach
```

## client

client 端用 spring boot 实现

#### amqp config

创建一个配置类

``` java

package common.rpc.amqp;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.CachingConnectionFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Created by work on 2017/6/22.
 */
@Configuration
public class AmqpConfig {
    // 创建一个 connectionFactory 对 amqp 的连接信息作配置
    public ConnectionFactory connectionFactory() {
        return new CachingConnectionFactory("localhost");
    }

    // 创建一个 rabbitTemplate 作为消息发送的模板
    // 这里有几个点需要注意
    // 为 rabbitTemplate 设置一个 jackson2MessageConverter，这样可以使用 rabbitTemplate.convertSendAndReceive 去收发消息，converter 会自动帮我们将对象转换成 json. 定义  这些对象的时候记得加@JsonProperty 这个注解来辅助 converter 的转换
    // 给 rabbitTemplate 设置 reply 地址，这样框架才会帮我们启动 messageListener 去收取对应的消息, server 端也可以利用这个地址，将回包发送到指定的队列
    @Bean
    public RabbitTemplate rabbitTemplate() {
        final RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory());
        rabbitTemplate.setMessageConverter(jackson2MessageConverter());
        rabbitTemplate.setReplyAddress("rpc/ssh-response");
        return rabbitTemplate;
    }

    @Bean
    public Jackson2JsonMessageConverter jackson2MessageConverter() {
        Jackson2JsonMessageConverter converter = new Jackson2JsonMessageConverter();
        return converter;
    }

    // 创建 MessageListenerContainer，将 container 和 rabbitTemplate 绑定，并设置监听的队列
    @Bean
    public SimpleMessageListenerContainer replyListenerContainer() {
        SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
        container.setConnectionFactory(connectionFactory());
        container.setQueues(replyQueue());
        container.setMessageListener(rabbitTemplate());
        return container;
    }

    // 创建一个收回包消息的队列
    @Bean
    public Queue replyQueue() {
        return new Queue("responses");
    }
}

```

#### 消息发送的部分代码

``` Java

// 创建一个 request 对象
Command command = new Command("set system host-name 666666");
// 将 request 发送到 rpc 交换机，路由键为 ssh-request，最终会被路由到 requests 队列
// 同时传入一个 MessageProcesser，将 MessageId 设置为 CommonResponse，server 端将 MessageId 填充到回包消息的 Headers["__TypeId__"], 这样 client 端在收到消息后才能被正确解析
Object rpcResponse = rabbitTemplate.convertSendAndReceive("rpc", "ssh-request", command, message -> {
            message.getMessageProperties().setMessageId(CommonResponse.class.getName());
            return message;
        });
```

## server

server 端用 go 实现

#### 实现 consumer

``` golang

package consumer

import (
	"fmt"
	"github.com/songtianyi/rrframework/logs"
	"github.com/streadway/amqp"
)

type Consumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel

	uri          string
	exchangeName string
	exchangeType string
	queueName    string
	routingKey   string
	consumerTag  string
	handler      Handler

	Done chan error

	sender *Responser
}

func NewConsumer(uri, exchangeName, exchangeType, queueName, routingKey, consumerTag string, handler Handler) (*Consumer, error) {
	var err error

	responser, err := NewResponser(uri)
	if err != nil {
		return nil, err
	}

	c := &Consumer{
		conn:    nil,
		channel: nil,

		uri:          uri,
		exchangeName: exchangeName,
		exchangeType: exchangeType,
		queueName:    queueName,
		routingKey:   routingKey,
		consumerTag:  consumerTag,
		handler:      handler,
		Done:         make(chan error),

		sender: responser,
	}

	logs.Info("Dialing %q", uri)
	c.conn, err = amqp.Dial(uri)
	if err != nil {
		return nil, fmt.Errorf("Dial: %s", err)
	}

	// watch connection
	go func() {
		c.Done <- fmt.Errorf("connection close: %s", <-c.conn.NotifyClose(make(chan *amqp.Error)))
	}()

	// open a new channel
	c.channel, err = c.conn.Channel()
	if err != nil {
		return nil, fmt.Errorf("Channel: %s", err)
	}

	// watch channel
	go func() {
		c.Done <- fmt.Errorf("channel close", <-c.channel.NotifyClose(make(chan *amqp.Error)))
	}()

	// declare exchange
	if err = c.channel.ExchangeDeclare(
		exchangeName, // name of the exchange
		exchangeType, // type
		true,         // durable
		false,        // delete when complete
		false,        // internal
		false,        // noWait
		nil,          // arguments
	); err != nil {
		return nil, fmt.Errorf("Exchange Declare: %s", err)
	}

	// declare queue
	queue, err := c.channel.QueueDeclare(
		queueName, // name of the queue
		true,      // durable
		false,     // delete when unused
		false,     // exclusive
		false,     // noWait
		nil,       // arguments
	)
	if err != nil {
		return nil, fmt.Errorf("Queue Declare: %s", err)
	}

	logs.Info("declared Queue (%q %d messages, %d consumers), binding to Exchange (key %q)",
		queue.Name, queue.Messages, queue.Consumers, routingKey)

	if err = c.channel.QueueBind(
		queue.Name,   // name of the queue
		routingKey,   // bindingKey
		exchangeName, // sourceExchange
		false,        // noWait
		nil,          // arguments
	); err != nil {
		return nil, fmt.Errorf("Queue Bind: %s", err)
	}

	logs.Info("Queue %s bound to Exchange %s, starting consumer %s", queue.Name, exchangeName, consumerTag)
	deliveries, err := c.channel.Consume(
		queue.Name,  // name
		consumerTag, // consumerTag,
		false,       // noAck
		false,       // exclusive
		false,       // noLocal
		false,       // noWait
		nil,         // arguments
	)
	if err != nil {
		return nil, fmt.Errorf("Queue Consume: %s", err)
	}

	// accept deliveries and handle them
	go c.handle(deliveries)

	return c, nil
}

func (s *Consumer) handle(deliveries <-chan amqp.Delivery) {
	for d := range deliveries {
		go func(d amqp.Delivery) {
			b := s.handler(d)
			d.Ack(false)
			s.sender.Send(d, b)
		}(d)
	}
	logs.Info("handle: deliveries channel closed")
}
```

写一个 main 程序，new 一个 consumer，监听 rpc 交换机的 request 队列，当收到消息时，往 rpc 交换机的 response 队列回 json 消息，路由键为 ssh-response。
