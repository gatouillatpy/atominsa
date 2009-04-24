@echo off
set path=%path%;"C:\Program Files\Java\jdk1.6.0_12\bin"
mkdir bin
cd src
javac -Xbootclasspath/p:..\lib\dbw.jar *.java
move /y *.class ..\bin
cd ..\bin
copy /y ..\login.inf login.inf
java -Xbootclasspath/p:..\lib\dbw.jar AtominsaMaster
cd..