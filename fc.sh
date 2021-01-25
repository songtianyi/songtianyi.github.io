#/bin/bash
# 字数统计

echo "Files count summary"
TOTAL=0

# 旧文章是用html写的

wc_files() {
	WC=`ls $1 | wc -l`
	echo $WC
}

# acm
acm=$(wc_files 'pages/acm/*-acm.html')
echo "ACM: $acm"

# career
career=$(wc_files 'pages/career/get-trapped.html pages/career/*.md')
echo "Career: $career"

# data-compression
dc=$(wc_files 'pages/data-compression/*-comp.html')
echo "Data compression: $dc"

# life
life=$(wc_files 'pages/life/*-life.html pages/life/master-of-sex.html pages/life/*.md')
echo "Life: $life"

# pieces
pieces=$(wc_files 'pages/pieces/*-other.html pages/pieces/songtianyi.dump.html pages/pieces/*.md pages/pieces/blog-stats.html')
echo "Pieces: $pieces"

# programming
programming=$(wc_files 'pages/programming/*/*.md')
echo "Programming: $programming"

# secure
secure=$(wc_files 'pages/secure/*-secure.html pages/secure/*.md')
echo "Secure: $secure"

# VDI
vdi=$(wc_files 'pages/vdi/*-vdi.html')
echo "VDI: $vdi"

# mdk
mdk=$(wc_files 'mdks/*.mdk')

# index
index=$(wc_files 'index.html')

echo "Total: " `expr $acm + $career + $life + $pieces + $programming + $secure + $vdi + $mdk + $index`

