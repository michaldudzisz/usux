#!/bin/sh

if [ $# -eq 0 ]; then
	echo Poprawne wywolanie programu: $0 arg1 arg2 ...
fi

NIC=0

LICZBA=1
NAW_ZAM=2
NAW_OTW=3
OPERATOR=4

NIE=0
TAK=1

DODAWANIE=1
ODEJMOWANIE=2
MNOZENIE=3
DZIELENIE=4

dzialanie_poza_nawiasem=$MNOZENIE
dzialanie_w_nawiasie=$MNOZENIE
dzialanie_tmp=$NIC

#para liczb poza nawiasem:
a=1 
b=$NIC 

#para liczb w nawiasie:
c=1
d=$NIC 

nawias_otwarty=$NIE 
poprzednia=-1 # potem przypisywane inne wartosci
ciag_argumentow=""


while [ "$1" ]; do

	case $1 in
		[\(] ) 
			echo mam nawias otwierajacy
			if [ $nawias_otwarty -eq $TAK ]; then
				echo Blad. Dozwolony poziom nawiasow: 1. Otworzono drugi nawias.
				exit 2
			fi 

			c=1
			dzialanie_w_nawiasie=$MNOZENIE

			nawias_otwarty=$TAK
			poprzednia=$NAW_OTW
			;;

		[\)] ) 
			echo mam nawias zamykajacy
			if [ $nawias_otwarty -eq $NIE ]; then
				echo Blad. Proba zamkniecia nieotworzonego nawiasu.
				exit 2
			fi

			case $dzialanie_poza_nawiasem in
				$DODAWANIE )
					a=`expr $a + $c`
					;;
				$ODEJMOWANIE )
					a=`expr $a - $c`
					;;
				$MNOZENIE )
					a=`expr $a \* $c`
					;;
				$DZIELENIE )
					a=`expr $a / $c`
					;;
			esac

			nawias_otwarty=$NIE
			poprzednia=$NAW_ZAM
			;;

		[+\-\*/] )
			echo mam operator
			if ! [ $poprzednia -eq $LICZBA -o $poprzednia -eq $NAW_ZAM ]; then
				echo Blad. Podano operator w niewlasciwym miejscu.
				exit 2
			fi

			case $1 in
				+ )
					dzialanie_tmp=$DODAWANIE
					;;
				- )
					dzialanie_tmp=$ODEJMOWANIE
					;;
				\* )
					dzialanie_tmp=$MNOZENIE
					;;
				/ )
					dzialanie_tmp=$DZIELENIE
					;;
			esac

			if [ $nawias_otwarty -eq $TAK ]; then
				dzialanie_w_nawiasie=$dzialanie_tmp
			else
				dzialanie_poza_nawiasem=$dzialanie_tmp
			fi
			
			poprzednia=$OPERATOR
			;;

		''|*[!0-9]* )
			echo mam cos gorszego niz liczba
			echo Blad. Okropienstwo.
			exit 2
			;;
		* )
			echo mam liczbe
			if [ $poprzednia -eq $LICZBA -o $poprzednia -eq $NAW_ZAM ]; then
				echo Blad. Liczba w niewlasciwym miejscu.
				exit 2
			fi

			if [ $nawias_otwarty -eq $TAK ]; then
				d=$1
			else
				b=$1
			fi

			case $nawias_otwarty in
				$NIE )
					case $dzialanie_poza_nawiasem in
						$DODAWANIE )
							a=`expr $a + $b`
							;;
						$ODEJMOWANIE )
							a=`expr $a - $b`
							;;
						$MNOZENIE )
							a=`expr $a \* $b`
							;;
						$DZIELENIE )
							a=`expr $a / $b`
							;;
					esac
					;;
				$TAK )
					case $dzialanie_w_nawiasie in
						$DODAWANIE )
							c=`expr $c + $d`
							;;
						$ODEJMOWANIE )
							c=`expr $c - $d`
							;;
						$MNOZENIE )
							c=`expr $c \* $d`
							;;
						$DZIELENIE )
							c=`expr $c / $d`
							;;
					esac
					;;
			esac

			poprzednia=$LICZBA
			;;
	esac
	if [ $poprzednia -eq $OPERATOR ]; then
		ciag_argumentow=$ciag_argumentow" \\"$1
	else
		ciag_argumentow="$ciag_argumentow $1"
	fi
	shift
done

if [ $nawias_otwarty -eq $TAK ]; then
	echo Blad. Niedomkniety nawias.
	exit 2
fi

echo $ciag_argumentow

echo $a
