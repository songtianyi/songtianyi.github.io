#/bin/bash
# 字数统计

echo "Files count summary"
TOTAL=0

# 旧文章是用html写的

wc_files() {
	WC=`ls $1 | wc -l`
	echo $WC
}

# drawio
drawio=$(wc_files 'pages/*/*/*.drawio')
echo "Drawio: $drawio"

# acm
acm=$(wc_files 'pages/acm/*-acm.html')
echo "ACM: $acm"

# career
career=$(wc_files 'pages/career/get-trapped.html pages/career/*.md')
echo "Career: $career"

# data-compression
dc=$(wc_files 'pages/data-compression/*-comp.html')
echo "Data compression: $dc"

# x-sports
xsports=$(wc_files 'pages/xsports/vietnam*.html pages/xsports/*.md')
echo "X-sports: $xsports"

# life
life=$(wc_files 'pages/life/*-life.html pages/life/master-of-sex.html pages/life/talk-to-me.html pages/life/*.md pages/life/native-english.html pages/life/how-to-write-your-blog.html pages/life/songtianyi.dump.html pages/life/*.md pages/life/blog-stats.html')
echo "Life: $life"

# programming
programming=$(wc_files 'pages/programming/*/*.md pages/programming/software-frameworks/ionic-dev.html pages/programming/software-frameworks/spring-boot-and-websocket.html pages/programming/uncategorized/questions-and-answers.html pages/programming/software-development-and-quality-assurance/elk-practice.html pages/programming/languages/about-shell.html pages/programming/languages/html5-intro.html pages/programming/languages/tencent-parser.html pages/programming/languages/getting-started-with-rust-in-1-hour.html')
echo "Programming: $programming"

# blockchain
blockchain=$(wc_files 'pages/blockchain/*.md' pages/blockchain/rsa.html)
echo "Blockchain: $blockchain"

# VDI
vdi=$(wc_files 'pages/vdi/*-vdi.html')
echo "VDI: $vdi"

# research
research=$(wc_files 'pages/academic-research/*/*.md')
echo "Research: $research"

# mdk
mdk=$(wc_files 'mdks/*.mdk')

# index
index=$(wc_files 'index.html' 'zh.html')

echo "Total: " `expr $acm + $career + $dc + $xsports + $life + $programming + $blockchain + $vdi + $research + $mdk + $index + $drawio`

