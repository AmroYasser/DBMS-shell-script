#!/bin/bash
`mkdir -p databases`

select_from(){
	clear
	read -p "Enter table name to select from: " tblname
	select choice in "select all" "select specific records"
	do
	case $REPLY in
		1)
		awk -F, '{if(NR==5){print}}' databases/$connectedDB/.$tblname"_metadata";
		awk -F, '{print}' databases/$connectedDB/$tblname

		;;
			
		2)
		pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
		read -p "Enter $pk_name value: " val;
		awk -F, '{if(NR==5){print}}' databases/$connectedDB/.$tblname"_metadata";
		cat databases/$connectedDB/$tblname | grep $val
		echo
		echo
		table
	esac
    done
	echo

}

delete_from(){
	clear
	read -p "Enter table name to delete from: " tblname
	select choice in "delete all records" "delete a specific record"
	do
	case $REPLY in
		1)
		> $tblname
		echo All records has been deleted

		;;
			
		2)
		pk_name=`awk -F, '{if(NR==5){print$1}}' databases/$connectedDB/.$tblname"_metadata";`
		read -p "Enter $pk_name value: " val;
		sed "/^$val/d"
		
	esac
    done
	echo
	table
}

table(){
choice=read
select choice in "create table" "list tables" "Drop table" "Show meta data of a table" "insert to table" "select from table" "delete from table" "Back to main menu"
	do
	case $REPLY in
	1)
	clear
	read -p "Enter a name for the table: " tblname
	if [[ -f databases/$connectedDB/$tblname ]];then
		echo table already exists
	else
		`touch databases/$connectedDB/$tblname`
		`touch databases/$connectedDB/.$tblname"_metadata"`
		`chmod -R 777 databases/$connectedDB/$tblname`
		echo "Table Name:"$tblname >> databases/$connectedDB/.$tblname"_metadata"

		read -p "Enter number of columns :" cols;
		echo "Number of columns:"$cols >> databases/$connectedDB/.$tblname"_metadata"
		

		for (( i = 1; i <= cols; i++ )); do
			if [[ i -eq 1 ]];then
				read -p "Enter column $i name as a primary key:" name;
				echo "The primary key for this table is: "$name >> databases/$connectedDB/.$tblname"_metadata";
				echo "Names of columns: " >> databases/$connectedDB/.$tblname"_metadata"
				echo -n $name"," >> databases/$connectedDB/.$tblname"_metadata";

			elif [[ i -eq cols ]];then
				read -p "Enter column $i name:" name;
				echo -n $name >> databases/$connectedDB/.$tblname"_metadata";
			else
				read -p "Enter column $i name:" name;
				echo -n $name"," >> databases/$connectedDB/.$tblname"_metadata";	
			fi
		done
		clear
		echo Table created sucsessfully
		table
	fi

	;;
	2)
	echo The tables of this database are: 
		ls databases/$connectedDB
		;;
	3)echo 
	clear
		read -p "Enter name of the table you want to drop:"
		if [[ -f databases/$connectedDB/$REPLY ]];then
			rm databases/$connectedDB/$REPLY
			echo table removed successfully
		else
			echo no table with this name
		fi
		;;
	4)
	read -p "Enter the table name: " tblname
	if [[ -f databases/$connectedDB/$tblname ]];then
			cat databases/$connectedDB/.$tblname"_metadata"
			echo
		else
			echo There is no table with this name
		fi
	;;
	

	5)
	clear
	read -p "Enter the table name: " tblname
	if [[ -f databases/$connectedDB/$tblname ]]; then
	typeset -i cols=`awk -F, '{if(NR==5){print NF}}' databases/$connectedDB/.$tblname"_metadata";`
	
	for (( i = 1; i <= $cols; i++ )); do
	 	colname=`awk -F, -v"i=$i" '{if(NR==5){print $i}}' databases/$connectedDB/.$tblname"_metadata";`
		read -p "Enter $colname: " value;
			if [[ $i != $cols ]]; then
				echo -n $value"," >> databases/$connectedDB/$tblname;
			else	
				echo $value >> databases/$connectedDB/$tblname;
			fi
	done
	echo "Data has been saved successfully"
	table
 	
	else
		echo "$tblname doesn't exist";
	fi
	;;
	6)
	select_from
	;;
	7)
	delete_from
	;;
	8)
		clear
		break 2
		;;
	*)
	clear
	echo "Wrong choice"
		table
	esac
done
}

echo Hello, `whoami`!! Welcom to our database managment system
while true
do
echo "Enter your choice"
PS3="Your Choice Is: "
choice=read
	select choice in "create database" "List Databases" "Connect to databases " "Drop Database" "Exit from DBMS" 
	do
	case $REPLY in
	1)
	clear
	read -p "Enter a name for the database: "; 
	if [[ -d databases/$REPLY ]];then
	echo 'Database already exists'	
	else  
	`mkdir databases/${REPLY}`
		echo ${REPLY} database created succsessfully!!!
		fi
		break
	;;
	2)
	clear
	echo The available databases are: 
	ls databases
	break
	;;
 	3)
	clear
	read -p "Enter the name of the database you want to connect with: "
	connectedDB=$REPLY
	if [[ -d databases/$connectedDB ]];then
		clear
		echo You are now connected to $connectedDB database
		table
	else
		echo No database with name $connectedDB
	fi 
	break
	;;
	4)
	clear
	read -p "Enter the name of the database you want to drop: "
	if [[ -d databases/$REPLY ]];then
		`rm -r databases/$REPLY`
		echo $REPLY dropped sucsessfully
	else
		echo their is no database with this name
	fi
	break
	;;
	5)
		exit
		;;
	*)echo $REPLY is  invalid choice
		break
 		;;
	esac
done
done


