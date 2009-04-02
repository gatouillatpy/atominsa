@echo off
set path=%path%;"C:\Program Files\Java\jdk1.6.0_05\bin"
mkdir bin
cd src
javac *.java
move /y *.class ..\bin
cd ..\bin
java -Xbootclasspath/p:..\lib\mysql-connector-java-5.1.7-bin.jar AtominsaMaster
cd..