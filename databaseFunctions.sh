#!/usr/bin/bash

source validationFunctions.sh
source tablesFunctions.sh

start(){
databases=() ; tables=() ; IFS=','
databaseActions=("create database","drop database","connect to database","list databases","quit")
tableActions=('create','drop','insert','display','update','delete','list','Home','quit')
dataTypes=('int','char') ; constrains=('primaryKey','unique','notNull','none')
if [[ ! -d "Databases" ]] ; then  
   mkdir Databases
fi
cd Databases
}

laodDatabases(){
  while read line ; do 
    databases[$i]="$line"
    (( i++ ))
  done< <(ls);
}

createDatabase(){
while true ; do
  read -p "What is the name of the database : " databaseName
  if [[ -d $databaseName ]] ; then
    echo "database ' $databaseName ' already exist"
    break   
  else
    charValidate $databaseName
    if [[ $pass == "success" ]] ; then
      mkdir $databaseName
      databases+=("$databaseName") 
      echo "database ' $databaseName ' is created successfully"
      break
    else
      echo "WARNING!! database name can not contain numbers or special chars !!"	
      echo " retype database name (chars only!) "
    fi     
  fi
done
} 

dropDatabase(){
if [[ ${#databases[@]} == 0 ]]; then 
  echo "there is no databases to drop "
else
  PS3="choose database you want to delete : " 
  select database in ${databases[@]} ; do
    if [[ -n $database ]] ; then
      rm -r $database
      for i in "${!databases[@]}"; do
        if [[ ${databases[i]} = $database ]]; then
          unset 'databases[i]'
        fi
      done
      echo "database ' $database ' deleted successfully"
      break 
    else
      echo "please select a listed database"
    fi
  done
fi
}

connect(){
if [[ ${#databases[@]} == 0 ]]; then 
  echo "there is no databases to connect to, create one first! " 
  connect="failed"
else
  PS3="which database you want to connect to : " 
  select database in ${databases[@]} ; do
    if [[ -n $database ]] ; then
      cd $database
      echo "connected to $database successfully "
      break
    else
      echo "please select a listed database"
    fi
  done
  connect="success"
fi
}

listDatabases(){
  echo "databases list >> "
  printf "< %s > \n" "${databases[@]}"
} 

quitScript(){
  read -p "Are you sure you want to quit [y/n]?  " replay
  if [[ $replay == "y" ]] || [[ $replay == "Y" ]] || [[ $replay == "yes" ]] || [[ $replay == "YES" ]] || [[ $replay == 1 ]] ; then
     quit="confirmed"
  else
     quit="notconfirmed" 
  fi
}
