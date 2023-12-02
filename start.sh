#!/usr/bin/bash
source databaseFunctions.sh
start

laodDatabases
while true ; do
  PS3="Choose your action :?  "
  select action in ${databaseActions[@]} ; do
    case $action in
      'create database'    )
                createDatabase ;;
      'drop database'      )   
                dropDatabase ;;
      'connect to database')
                  connect
                  if [[ $connect == "failed" ]] ; then  
                    break
                  else
                    laodTables
                    tableActionsMenu 
                  fi;;
      'list databases'     )
                listDatabases ;;
      'quit'               ) 
                quitScript ;;
      *                    ) 
                echo "Not valide input!" ;;
    esac
    break
  done
  if [[ $quit = "confirmed" ]]; then
    break
  fi
done
