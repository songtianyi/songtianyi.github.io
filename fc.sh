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
life=$(wc_files 'pages/life/*-life.html pages/life/master-of-sex.html pages/life/talk-to-me.html pages/life/*.md')
echo "Life: $life"

# pieces
pieces=$(wc_files 'pages/pieces/kindle-touch.html pages/pieces/native-english.html pages/pieces/how-to-write-your-blog.html pages/pieces/songtianyi.dump.html pages/pieces/*.md pages/pieces/blog-stats.html')
echo "Pieces: $pieces"

# programming
programming=$(wc_files 'pages/programming/*/*.md pages/programming/data-structure-and-algorithms/rsa.html pages/programming/software-frameworks/ionic-dev.html pages/programming/software-frameworks/spring-boot-and-websocket.html pages/programming/uncategorized/questions-and-answers.html pages/programming/software-development-and-quality-assurance/elk-practice.html pages/programming/programming-languages/about-shell.html pages/programming/programming-languages/html5-intro.html pages/programming/programming-languages/tencent-parser.html')
echo "Programming: $programming"

# blockchain
blockchain=$(wc_files 'pages/blockchain/*.md')
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
index=$(wc_files 'index.html')

echo "Total: " `expr $acm + $career + $dc + $xsports + $life + $pieces + $programming + $blockchain + $vdi + $research + $mdk + $index + $drawio`

