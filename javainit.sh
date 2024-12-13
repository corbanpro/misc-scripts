#!/bin/bash
touch build.xml
mkdir src
touch src/Main.java
echo '<project>
    <target name="clean">
        <delete dir="build"/>
    </target>

    <target name="run">
        <mkdir dir="build/classes"/>
        <javac srcdir="src" destdir="build/classes" includeantruntime="false"/>
        <mkdir dir="build/jar"/>
        <jar destfile="build/jar/Main.jar" basedir="build/classes">
            <manifest>
                <attribute name="Main-Class" value="Main"/>
            </manifest>
        </jar>
        <java jar="build/jar/Main.jar" fork="true"/>
    </target>
</project>' >build.xml

echo 'public class Main {
  public static void main(String[] args) {
    System.out.println("Hello World");
  }
}' >src/Main.java
