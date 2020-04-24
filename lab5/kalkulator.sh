#!/bin/sh

# Skrypt nie rozpoznaje kolejnosci wykonywania dzialan oprocz pierwszenstwa dla 
# jednego poziomu nawiasow. Nie przyjmuje liczb ujemnych i wymaga poprzedzania znakow
# (, ), * znakiem "\". Liczby, operatory i nawiasy sa podawane jako kolejne
# argumenty wywolania skryptu, zatem nalezy je oddzielac spacja.

if [ $# -eq 0 ]; then
	echo Poprawne wywolanie programu: $0 arg1 arg2 ...
fi

NIC=0

# "stale" dla zmiennej poprzednia, ktora przechowuje rodzaj poprzednio wczytanego znaku,
# by sprawdzic, czy wyrazenie jest poprawnie skonstruane
LICZBA=1
NAW_ZAM=2
NAW_OTW=3
OPERATOR=4

NIE=0
TAK=1

# stale mapowania znakow arytmetycznych
DODAWANIE=1
ODEJMOWANIE=2
MNOZENIE=3
DZIELENIE=4

# Jak dziala skrypt: przechodzi wyrazenie od lewej do prawej rozwiazujac je na biezaco.
# Oblsuguje jeden poziom nawiasow, w ktore moze wejsc zapamietujac wynik i operator
# sprzed nawiasu. Stad zmienne dzialanie_poza_nawiasem i dzialanie_w_nawiasie
# opisujace ostatnie operatory po lewej odpowiednio przed i w nawiasie. 
# Inicjowane mnozeniem, gdyz odczyt pierwszej liczby zostal zrealizowany jako
# mnozenie jej razy 1. Stad inicjacja a=1 i c=1. 

dzialanie_poza_nawiasem=$MNOZENIE
dzialanie_w_nawiasie=$MNOZENIE
dzialanie_tmp=$NIC

# para liczb potrzebna do obliczen poza nawiasem:
a=1 
b=$NIC 

# para liczb potrzebna do obliczen w nawiasie:
c=1
d=$NIC 

nawias_otwarty=$NIE 
poprzednia=-1 # potem przypisywane inne wartosci
ciag_argumentow=""


while [ "$1" ]; do

	case $1 in
		[\(] ) #wczytano nawias otwierajacy
			if [ $nawias_otwarty -eq $TAK ]; then
				echo Blad. Dozwolony poziom nawiasow: 1. Otworzono drugi nawias.
				echo "Dozwolone znaki: ( ) + - * / oraz liczby calkowite dodatnie."
				echo "Liczby oddziel od operatorow i nawiasow spacjami."
				echo "Znaki niebedace liczbami (( ) + - * /) poprzedz znakiem \ ."
				exit 2
			fi 

			c=1
			dzialanie_w_nawiasie=$MNOZENIE

			nawias_otwarty=$TAK
			poprzednia=$NAW_OTW
			;;

		[\)] ) # wczytano nawias zamykajacy
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

		[+\-\*/] ) # wczytano operator
			if ! [ $poprzednia -eq $LICZBA -o $poprzednia -eq $NAW_ZAM ]; then
				echo Blad. Podano operator w niewlasciwym miejscu.
				echo "Dozwolone znaki: ( ) + - * / oraz liczby calkowite dodatnie."
				echo "Liczby oddziel od operatorow i nawiasow spacjami."
				echo "Znaki niebedace liczbami (( ) + - * /) poprzedz znakiem \ ."
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

		''|*[!0-9]* ) # znaleziono sekwencje nieskladajaca sie z samych cyfr, ani nie bedaca jedna z powyzszych
			echo Blad. Podana sekwencja znakow nie jest nawiasem, dozwolonym operatorem lub liczba.
			echo "Dozwolone znaki: ( ) + - * / oraz liczby calkowite dodatnie."
			echo "Liczby oddziel od operatorow i nawiasow spacjami."
			echo "Znaki niebedace liczbami (( ) + - * /) poprzedz znakiem \ ."
			exit 2
			;;
		* ) # wczytano liczbe
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
	echo "Dozwolone znaki: ( ) + - * / oraz liczby calkowite dodatnie."
	echo "Liczby oddziel od operatorow i nawiasow spacjami."
	echo "Znaki niebedace liczbami (( ) + - * /) poprzedz znakiem \ ."
	exit 2
fi

echo Podano dzialanie: $ciag_argumentow

echo $a
