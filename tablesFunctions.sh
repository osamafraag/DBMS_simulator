#!/usr/bin/bash

source validationFunctions.sh

laodTables(){
  while read line ; do 
    tables[$i]="$line"
    (( i++ ))
  done< <(ls);
}

tableMenu(){
PS3="choose table you want to act in : " 
select table in ${tables[@]} ; do
  if [[ -n $table ]] ; then
     break 
  else
    echo "please select a listed table"
  fi
done
}

listTables(){
  echo "tables list >> "
  printf "< %s > \n" "${tables[@]}"
} 

tableActionsMenu(){
while true ; do
  PS3="which action you want : "
  select action in ${tableActions[@]}; do
    if [ -n "${action}" ] ; then
      case $action in
      'create' ) createTable ;;
      'list'   ) listTables ;;
      'Home'   ) ;;
      'quit'   ) quitScript ;;
      * )
      if [[ ${#tables[@]} == 0 ]]; then 
        echo "there is no tables in this database, create first"
      else
        tableMenu
        case $action in
          'drop'   ) dropTable ;;
          'insert' ) insertInto ;;
          'display') display ;;
          'update' ) update ;;
          'delete' ) delete ;;
        esac
      fi;;
      esac
    else
      echo "Not valide input!"
    fi
    break
  done
  if [[ "${action}" = "Home" ]] || [[ $quit = "confirmed" ]] ; then
    cd ..
    break
  fi
done
}

readTableName(){
while true ; do
  read -p "What is the table name ?  :  " tableName
  charValidate $tableName
  if [[ $pass == "success" ]] ; then
    break
  else
    echo "WARNING!! table name can not contain numbers or special chars !!"	
    echo " retype table name (chars only!) "
  fi 
done
}

readColNum(){
while true ; do
  read -p "How many column in the table:  " colNum
  intValidate $colNum
  if [[ $pass != "success" ]] ; then
    echo "please inter a valide number!"
  else
    break
  fi
done
}

readColName(){
while true ; do
  read -p "What is the name of the $i column: " colName
  charValidate $colName
  if [[ $pass != "success" ]] ; then
    echo "column name can not contain numbers or special chars!"
  else
    break
  fi
done
}

selectDataType(){
PS3="what is $colName datatype : "
select datatype in ${dataTypes[@]} ; do
  if [[ -n "$datatype" ]] ; then
    break
  else
    echo "Not valide input!"
  fi
done
}

selectConstrain(){
  PS3="what is $colName constrain : "  
  select constrain in ${constrains[@]} ; do
    if [[ -n "$constrain" ]] ; then
      if [[ $constrain == "primaryKey" ]] && [[ $flag == 1 ]] ; then
        echo "duplicate PK not allowed"
      else
        break
     fi
  else
      echo "Not valide input!"
    fi
  done
}

createTable(){
readTableName
if [[ -f $tableName ]] ; then
  echo "table ' $tableName ' already exist" 
else
  touch $tableName
  tables+=("$tableName")
  readColNum
  flag=0
  for (( i=1 ; i<=$colNum ; i++ )) ; do
    readColName
    selectDataType
    selectConstrain 
    if [[ $constrain == "primaryKey" ]] ; then
      flag=1
    fi
    echo -n "$colName($datatype-$constrain):" >> $tableName
  done
  echo "table ' $tableName ' is created successfully"
  echo $'\n' >> $tableName
fi
}

dropTable(){
read -p "are you sure you want to delete $table! [y/n] : " replay 
if [[ $replay == "y" || $replay == "Y" || $replay == "yes" || $replay == "YES" || $replay == 1 ]] ; then
  rm -r $table
  for i in "${!tables[@]}"; do
    if [[ ${tables[i]} = $table ]]; then
      unset 'tables[i]'
      echo "table ' $table ' deleted successfully"
    fi
  done
fi
}

get(){
  dataType=`head -1 $table | cut -f$1 -d":" | grep -o "int"`
  if [[ -z $dataType ]] ; then
    dataType=`head -1 $table | cut -f$1 -d":" | grep -o "char"`
  fi
  constrain=`head -1 $table | cut -f$1 -d":" | grep -o "primaryKey"`
  if [[ -z $constrain ]] ; then
    constrain=`head -1 $table | cut -f$1 -d":" | grep -o "unique"`
    if [[ -z $constrain ]] ; then
      constrain=`head -1 $table | cut -f$1 -d":" | grep -o "notNull"`
      if [[ -z $constrain ]] ; then
        constrain=`head -1 $table | cut -f$1 -d":" | grep -o "none"`
      fi
    fi
  fi
 }
 
condition(){
 if [[ $dataType == "int" ]] ; then
    intValidate $1
  else
    charValidate $1
  fi
  if [[ $pass != "success" ]] ;then
    echo "datatype not correct , try again!"
    return 0
  fi
  if [[ $constrain == "primaryKey" ]] ; then
    isPrimary $data $2
  elif [[ $constrain == "unique" ]] ; then
    isUnique $1 $2
  elif [[ $constrain == "notNull" ]] ; then
    isNull $data
  else
    pass="success"
  fi
  if [[ $pass != "success" ]] ;then
    echo "constrains is not correct , try again!"
    return 0
  fi
}

insertInto(){
fieldNum=`head -1 $table | grep -o ":" | wc -l`
for ((i=1;i <= fieldNum;i++)) ; do      
  row=`head -1 $table | cut -f$i -d":"`
  get $i
while true ; do
  read -p "what is the $row? : " data
  condition $data $i
  if [[ $pass != "success" ]] ;then
    continue
  fi 
  echo -n "$data:" >> $table
  break
done
done
echo $'\n' >> $table
}  


display(){
  awk 'BEGIN{FS=":"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i }{print "--|"}}}' $table
  read -p "display all records? [y/n] " replay
  if [[ $replay == "y" || $replay == "Y" || $replay == "yes" || $replay == "YES" || $replay == 1 ]] ; then
    read -p "display all fields? [y/n] " replay
    if [[ $replay == "y" || $replay == "Y" || $replay == "yes" || $replay == "YES" || $replay == 1 ]] ; then				
      column -t -s ':' $table
    else
      read -p "field index ? : " index
      awk $'{print $0\n}' $table | cut -f$index -d":"
    fi
  else
    read -p "search value ? : " value
    read -p "display all fields? [y/n] " replay
    if [[ $replay == "y" || $replay == "Y" || $replay == "yes" || $replay == "YES" || $replay == 1 ]] ; then				
      awk -v pat=$value '$0~pat{print $0}' $table | column -t -s ':'
    else
      read -p "field index ? : " index
      awk -v pat=$value $'$0~pat{print $0\n}' $table | cut -f$index -d":"
    fi
  fi
}


update(){
  awk 'BEGIN{FS=":"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $table
  read -p "field name ? " field
  charValidate $field
  fieldNum=`head -1 $table | grep -o ":" | wc -l`
  for ((i=1;i <= fieldNum;i++)) ; do 
  if [[ $field"(" == `head -1 $table | cut -f$i -d":" | grep -o $field"("` ]] ; then
     field=`head -1 $table | cut -f$i -d":"`
     break
  fi
  done
  found=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print $i }}}' $table )
  if [[ $found == "" ]] ; then
    echo "Not Found"
  else
    read -p "value ? " value
    NF=$(awk -v pat=$found 'BEGIN{FS=":"}{for(i=1;i<=NF;i++){if($i==pat){print i}}}' $table)
    get $NF
    oldValue=$(awk -v pat=$NF -v val=$value 'BEGIN{FS=":"}{for(i=1;i<=NF;i++){if(i==pat){if($i==val){print($i)}}}}' $table)
    if [[ $oldValue == "" ]] ; then
      echo "Value Not Found"
    else
    while true ; do
      read -p "new value ? " newValue
      condition $newValue $NF
      if [[ $pass != "failed" ]] ; then
        break
      fi
    done
      NR=$(awk -v pat=$NF -v val=$value 'BEGIN{FS=":"}{for(i=1;i<=NF;i++){if(i==pat){if($i==val){print(NR)}}}}' $table)
      sed -i ''$NR's/'$oldValue'/'$newValue'/g' $table
      echo "Row Updated Successfully"
    fi
  fi
}


delete(){
  awk 'BEGIN{FS=":"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $table
  read -p "field name ? " field
  fieldNum=`head -1 $table | grep -o ":" | wc -l`
  for ((i=1;i <= fieldNum;i++)) ; do 
  if [[ $field"(" == `head -1 $table | cut -f$i -d":" | grep -o $field"("` ]] ; then
     field=`head -1 $table | cut -f$i -d":"`
     break
  fi
  done
  found=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print $i }}}' $table)
  if [[ $found == "" ]] ; then
    echo "Not Found"
  else
    read -p "field value ? " value
    NF=$(awk -v pat=$found 'BEGIN{FS=":"}{for(i=1;i<=NF;i++){if($i==pat){print i}}}' $table)
    NR=$(awk -v pat=$NF -v val=$value 'BEGIN{FS=":"}{for(i=1;i<=NF;i++){if(i==pat){if($i==val){print(NR)}}}}' $table)
    if [[ $NR == "" ]] ; then
      echo "Value Not Found"
    else
      sed -i ''$NR'd' $table
     echo "Row Deleted Successfully"
    fi
  fi
}

