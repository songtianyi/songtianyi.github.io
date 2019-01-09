# 防火墙论文阅读笔记

### Firewall Policy Diagram

[《Firewall Policy Diagram: Novel Data Structures and Algorithms for Modeling, Analysis, and Comprehension of Network Firewalls》](https://kuscholarworks.ku.edu/bitstream/handle/1808/11462/Clark_ku_0099D_12729_DATA_1.pdf;sequence=1)

##### 防火墙使用情况

* In a study finished in 2009, it was determined that the growth in complexity has out paced the growth in the organization’s ability to synthesize and comprehend the changes [Chapple et al., 2009]. The average number of rules has substantially increased from 150 in 2001 to 793, with the largest rule set found comprised of 17,000 rules [Chapple et al., 2009]. The study did not discuss the number of firewalls deployed, but in the unlikely case that firewall deployment growth stopped and the number of firewalls at an average organization stayed at 200 [Wool, 2004], then approximately 160,000 rules (200×793) would be under active management. In addition, the study also discovered that the average
  rule turnover (change) rate for an organization is 9.9% of the rules per month [Chapple et al.,
  2009]. This means that the average firewall administration team has to accurately manage
  about 160,000 rules where 16,000 of those rules are changing on a monthly basis.

##### Packet filter parameters 
* IP source or destination address
* Protocol type: TCP, UDP, ICMP, etc.
* TCP or UDP source and destination port
* ICMP message type
* Different rules for ingress or egress routing • Different rules for different router interfaces


### Algorithms for Analysing Firewall and Router Access Lists

[《Algorithms for Analysing Firewall and Router Access Lists》](https://www.researchgate.net/publication/2300371/download)

##### 	Converting rule sets into boolean expressions

```bash
access-list 101 permit tcp 20.9.17.8  255.255.255.255 121.11.127.20 255.255.255.255 range 23 27
```

1. Representing numbers as bit-vectors, examples:

   ![image](http://owm6k6w0y.bkt.clouddn.com/20.9.17.8-bool-expression.png)

   ​

   ![image](http://owm6k6w0y.bkt.clouddn.com/128.0.0.0:8-bool-expression.png)



### A Firewall Application Using Binary Decision Diagram

[《A Firewall Application Using Binary Decision Diagram》](http://dpi-proceedings.com/index.php/dtcse/article/viewFile/8909/8478)

* BDD is used to do the redundancy removal of firewalls
  * CUDD package provides a lot of basic procedure for manipulating BDDs	

##### Redundancy Removal Using BDD

- convert every firewall rule into one or multiple binary format rules，and record the mapping information. One firewall rule maps to one or multiple binary format rules.

  32,32,16,16,8,1 = 105bit

- convert every binary into BDD

- upward and downward redundancy removal, in these steps, we detect all redundant binary format rules

- get original redundancy with the mapping information

  ​

### Complete Redundancy Detection in Firewalls

[《Complete Redundancy Detection in Firewalls》](https://web.cse.msu.edu/~alexliu/publications/Redundancy/redundancy.pdf)

​		

### THE GEOMETRIC EFFICIENT MATCHING ALGORITHM FOR FIREWALLS EXTENDED ABSTRACT

[《THE GEOMETRIC EFFICIENT MATCHING ALGORITHM FOR FIREWALLS EXTENDED ABSTRACT》](https://www.eng.tau.ac.il/~yash/ieeei04-gem.pdf)		

Every rule consists of set of ranges [l<sub>i</sub> , r<sub>i</sub> ] for i = 1, . . . , *d* (*d* is the number of fields to match), where each range corresponds to the i-th field in a packet header. The field values are in 0 ≤ l<sub>i</sub>,r<sub>i</sub>≤ U<sub>i</sub>,where U<sub>i</sub> = 2^32 − 1 for IP addresses, U<sub>i</sub> = 65535 for portnumbers, and U<sub>i</sub> = 255 for ICMP message type or code.

- We use ‘∗’ to denote wildcard: An ‘∗’ in field i meansany value in [0, U<sub>i</sub>].
- We are ignoring the action part of the rule (e.g., pass or drop), since we are only interested in the matching algorithm.



### Efficient Techniques for Fast Packet Classification

[《Efficient Techniques for Fast Packet Classification》](https://pdfs.semanticscholar.org/6e41/003adff1179f3bea0765743877a699b7f49e.pdf)

### Network Firewall Policy Tries

[《Network Firewall Policy Tries》](https://pdfs.semanticscholar.org/bca2/0ba743daf0b9a786fe3d5faa90d53a9a7344.pdf)



### COMPARISON OF ALGORITHMS FOR DETECTING FIREWALL POLICY ANOMALIES 

[《COMPARISON OF ALGORITHMS FOR DETECTING FIREWALL POLICY ANOMALIES》](http://www.iraj.in/journal/journal_file/journal_pdf/3-218-145413332618-22.pdf)



### 参考资料​​​


​		
​	
