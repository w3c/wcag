#!/bin/bash
echo "<techniques>"
for dir in techniques/*
do
  echo "<technology type=\"$dir\">"
  for file in $dir/*
  do 
    echo "<technique id=\"$file\"/>"
  done
  echo "</technology>"
done
echo "</techniques>"