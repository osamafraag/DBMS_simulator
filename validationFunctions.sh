#!/usr/bin/bash

intValidate(){
  if [[ $1 != *[[:lower:]]* ]] && [[ $1 != *[[:upper:]]* ]] && [[ $1 != *['!'@#\$%^\&*()_+:]* ]] ; then 
    pass="success"
  else
    echo "data must be of int type"
    pass="failed"
  fi
}

charValidate(){
  if [[ $1 != *[0-9]* ]] && [[ $1 != *['!'@#\$%^\&*()_+:]* ]] ; then 
    pass="success"
  else
    echo "data must be of char type"
    pass="failed"
  fi
} 

isUnique(){
  pass=$(awk -v pat=$1 -v field=$2 'BEGIN{FS=":"}{if($field==pat){print("failed")}}' $table)
  if [[ $pass != "failed" ]] ; then
    pass="success"
  fi
}  
 
isNull(){
 if [[ -z $1 ]]; then
   echo "Error: $1 cannot be empty"
   pass="faild"
 else
   pass="success"
 fi
}

isPrimary(){
  isUnique $data $i
  if [[ $pass == "success" ]] ; then
    isNull $1
  fi
}
