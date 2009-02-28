@set path=%path%;"C:\Program Files\Java\jdk1.6.0_12\bin"
@cd src
@javac *.java
@move /y *.class ..\bin
@cd ..\bin
@java AtominsaMaster
@cd..