#!/bin/bash

#----------------------------------------------------------------------+
#Color picker, usage: printf ${BLD}${CUR}${RED}${BBLU}"Some text"${DEF}|
#---------------------------+--------------------------------+---------+
#        Text color         |       Background color         |         |
#------------+--------------+--------------+-----------------+         |
#    Base    |Lighter\Darker|    Base      | Lighter\Darker  |         |
#------------+--------------+--------------+-----------------+         |
RED='\e[31m'; LRED='\e[91m'; BRED='\e[41m'; BLRED='\e[101m' #| Red     |
GRN='\e[32m'; LGRN='\e[92m'; BGRN='\e[42m'; BLGRN='\e[102m' #| Green   |
YLW='\e[33m'; LYLW='\e[93m'; BYLW='\e[43m'; BLYLW='\e[103m' #| Yellow  |
BLU='\e[34m'; LBLU='\e[94m'; BBLU='\e[44m'; BLBLU='\e[104m' #| Blue    |
MGN='\e[35m'; LMGN='\e[95m'; BMGN='\e[45m'; BLMGN='\e[105m' #| Magenta |
CYN='\e[36m'; LCYN='\e[96m'; BCYN='\e[46m'; BLCYN='\e[106m' #| Cyan    |
GRY='\e[37m'; DGRY='\e[90m'; BGRY='\e[47m'; BDGRY='\e[100m' #| Gray    |
#------------------------------------------------------------+---------+
# Effects                                                              |
#----------------------------------------------------------------------+
DEF='\e[0m'   # Default color and effects                              |
BLD='\e[1m'   # Bold\brighter                                          |
DIM='\e[2m'   # Dim\darker                                             |
CUR='\e[3m'   # Italic font                                            |
UND='\e[4m'   # Underline                                              |
INV='\e[7m'   # Inverted                                               |
COF='\e[?25l' # Cursor Off                                             |
CON='\e[?25h' # Cursor On                                              |
#----------------------------------------------------------------------+
# Text positioning, usage: XY 10 10 "Some text"                        |
XY   () { printf "\e[${1};${2}H${3}";   } #                            |
#----------------------------------------------------------------------+
# Line, usage: line - 10 | line -= 20 | line "word1 word2 " 20         |
line () { printf %.s"${1}" $(seq ${2}); } #                            |
#----------------------------------------------------------------------+

P=1
X=0
Y=0
n=8
c=$((n*n-2))
q=$((2))
A=( )
B=( )
C=($GRY $RED $BLU $GRN $YLW $CYN $MGN)
G=( 25 25 25 25 25 25 25 )
Q=( 0  0  0  0  0  0  0)

gen () { 
	for i in $(seq 0 $((n))) 
	do
		for j in $(seq 0 $((n))) 
		do
			B[$((i*n+j))]=0
			if (($i>0)) 
			then
				A[$((n*i+j))]=$((A[$((n*i+j))]+A[$((n*(i-1)+j))/2]))
			fi
			if (($j>0))
			then
				A[$((n*i+j))]=$((A[$((n*i+j))]+A[$((n*i-1+j))/2]))
			fi
			A[$((n*i+j))]=$((RANDOM%4-1))
			if ((${A[$((n*i+j))]}<0))
			then
				A[$((n*i+j))]=0
			fi
		done
	done
}

print(){
	clear	
	echo -en "  "
	for i in $(seq 0 $((n-1)))
	do
		echo -en ${DGRY} ${i}
	done
	echo ""
	for i in $(seq 0 $((n-1))) 
	do
		echo -en ${DGRY} ${i} 
		for j in $(seq 0 $((n-1))) 
		do
			if (($i==$X))&&(($j==$Y))
			then
				echo -en " ${C[${B[$((i*n+j))]}]}$BDGRY${A[$((i*n+j))]}$DEF"

			else
				echo -en ${C[${B[$((i*n+j))]}]} ${A[$((i*n+j))]}
			fi
		done
		echo ""
	done
	if (($P==1))
	then
		echo -en $RED ${BDGRY}P1: ${G[1]}$DEF $BLU  P2: ${G[2]}
	else
		echo -en $RED P1: ${G[1]} $RED ${BDGRY}$BLU  P2: ${G[2]}$DEF
	fi
	echo ""
}

start(){
	x=$((RANDOM%n))
	y=$((RANDOM%n))
	B[$((x*n+y))]=1
	x=$((RANDOM%n))
	y=$((RANDOM%n))
	B[$((x*n+y))]=2
}

gplus(){
	for i in $(seq 0 $((n-1))) 
	do 
		for j in $(seq 0 $((n-1))) 
		do
			fg=$((${G[${B[$((i*n+j))]}]}+${A[$((i*n+j))]}))
			G[${B[$((i*n+j))]}]=$fg
		done
	done
}

gminus(){
	for i in $(seq 0 $((n-1))) 
	do 
		for j in $(seq 0 $((n-1))) 
		do
			fg=$((${G[${B[$((i*n+j))]}]}-${A[$((i*n+j))]}))
			G[${B[$((i*n+j))]}]=$fg
		done
	done
}

buy(){
	if (((($X>0))&&((${B[$(((X-1)*n+Y))]}==$P))))||(((($Y>0))&&((${B[$((X*n+Y-1))]}==$P))))||(((($X<$((n-1))))&&((${B[$(((X+1)*n+Y))]}==$P))))||(((($Y<$((n-1))))&&((${B[$((X*n+Y+1))]}==$P))))
	then
		c=$((c-1))
		G[$P]=$((${G[$P]}-10-${A[$((X*n+Y))]}))
		B[$((${X}*n+${Y}))]=$P
	fi
}

trap bye INT
printf "${COF}"
stty -echo
clear

gen
start
while (($c>0))
do
	print
	if (($q==0))
	then
		break
	fi
	while true 
	do
		if ((${G[$P]}<10))||((${Q[$P]}==1))
		then
			break
		fi
		read -n1 input
		case $input in
			"w")
				XY $((X+2)) $((2*(Y+1)+1)) "${C[${B[$((X*n+Y))]}]} ${A[$((X*n+Y))]}"
				((X--))
				if ((X<0))
				then
					((X++))
				fi
				XY $((X+2)) $((2*(Y+1)+1)) " ${C[${B[$((X*n+Y))]}]}$BDGRY${A[$((X*n+Y))]}$DEF";;
			"a")
				XY $((X+2)) $((2*(Y+1)+1)) "${C[${B[$((X*n+Y))]}]} ${A[$((X*n+Y))]}" 
				((Y--))
				if ((Y<0))
				then
					((Y++))
				fi
				XY $((X+2)) $((2*(Y+1)+1)) " ${C[${B[$((X*n+Y))]}]}$BDGRY${A[$((X*n+Y))]}$DEF";;
			"s")
				XY $((X+2)) $((2*(Y+1)+1)) "${C[${B[$((X*n+Y))]}]} ${A[$((X*n+Y))]}"
				((X++))
				if ((X+1>n))
				then
					((X--))
				fi
				XY $((X+2)) $((2*(Y+1)+1)) " ${C[${B[$((X*n+Y))]}]}$BDGRY${A[$((X*n+Y))]}$DEF";;
			"d")
				XY $((X+2)) $((2*(Y+1)+1)) "${C[${B[$((X*n+Y))]}]} ${A[$((X*n+Y))]}"
				((Y++))
				if ((Y+1>n))
				then
					((Y--))
				fi
				XY $((X+2)) $((2*(Y+1)+1)) " ${C[${B[$((X*n+Y))]}]}$BDGRY${A[$((X*n+Y))]}$DEF";;
			"b")
				if ((${B[$((X*n+Y))]}==0))
				then
					buy
					if ((${B[$((X*n+Y))]}>0))
					then
						break
					fi
				fi;;
			"q")
				Q[$P]=$((1))
				q=$((q-1))
				break;;
			"p")
				break;;
		esac
	done
	gplus
	P=$((P%2+1))
done
print

stty echo
if ((${G[1]}>${G[2]}))
then
	echo -en "${CON}${GRY}" Player 1 win!
fi
if ((${G[1]}==${G[2]}))
then
	echo -en "${CON}${GRY}" Draw!
fi
if ((${G[1]}<${G[2]}))
then
	echo -en "${CON}${GRY}" Player 2 win!
fi
echo ""
exit



