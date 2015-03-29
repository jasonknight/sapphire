# Sapphire

Sapphire is meant to be take two of my original effort Peridot written in C++11 using clang. Sapphire however will be written in Scheme. 

## The Language

    ; Defining a procedure/function
    
    (procedure myadd (a b) {
    	(+ a b)
    })
    
    (myadd 2 5)
    
    ; Looping
    (times 5 do {
    	(print "Hello World\n")
    })
    
    (from 1 to 5 do {
    	(print "Hello World\n")
    })
    
    ; Bind an argument to the loop
    
    (each my-hash-variable as (k v) do {
    	(print "#{k} = #{v}\n")
    })
    
    (times 5 as (i) do {
    	(print "#{i} Hello World \n")
    })

## Design Intentions

* Interactive Compiler: From the ground up the language is intended to be compiled.
* Deployment Tool: Writing a program is meaningless unless we can "deploy" or "deliver" that program to end users.
* Comments are part of the program: There is a never ending serious of laments about the lack of documentation and comments. When there isn't a lack, there is a standard/style guide flame war. We are going to head that off at the pass by simply making formatting, indentation, and commenting part of the language itself. 
* Purely functional: This means everything is a function, and everything is can/should be done with functions.

### Interactive Compiler

The design ideas behind the language is that it will be 
both interpreted and compiled. 

The definition of each and every function is kept as input, and
can be executed interactively in a REPL session. When done, the
entire program can be written to source code to be read in and
allow continuous development.

When it is finished, you would create a main procedure, and
then compile.

Example:

    > (procedure greet (name) do {
    	(print "Hello #{name}\n");
    	(exit 0)
    })
    => Procedure "greet" stored.
    > (procedure main(args) do {
    	(print "\nYour name? ")
    	(= name (trim gets))
    	(greet name)
    })
    => Procedure "main" stored.
    > (compile "myprog")
    => Compiled to /home/username/.../myprog.
    
    $ ./myprog
    Your name? Sapphire
    Hello Sapphire
    $    

So we can define the first design intention that it be an interactive compiler.

### Deployment Tool

The second design intention is that it be it's own deployment tool, that it
knows about deploying to a server, and that it knows some generic method
of configuring itself.

More specifically it can compile any code it receives, and that it can be
installed on a system and receive code from another server that it can compile
and deploy, similar in idea to how RSYNC works, in fact RSYNC may eventually
be used to upload new code. The actual implementation details should be
hidden from the user unless he so chooses to alter them.

Because the REPL is scriptable, it should not be very problematic to
setup the deployment environment from one interpreter to another, as the READ
of one is simply the WRITE of another.

### Comments are part of the program

The third design intention is perhaps the most important: Comments are program 
components. Every procedure can and perhaps must be documented with a structured
comment. You don't get to decide how to comment your code, there will be a format
for the comments, and you will receive whiny warnings if any procedure is not
commented.

Comments for a function can be grabbed with:

    (comments-for proc-name)
    =>
    ; Name: proc-name
    ; Arguments: string name, number i
    ; Purpose:
    ;   Prints the $name $i times
    ; Returns: nil
    ...
    ; Here is where we print
    4: (print "#{name}\n")

The idea being that the comments-for function is to get the heading comment which is just before the (procedure ...) call and all other comments in the function numbered from 1 being
the (procedure ...) line. So the 4: means 3 lines from the call to (procedure ...).

You can also print out the full code of the function:

    (code-for proc-name)
    =>
    ; Name: proc-name
    ; Arguments: string name, number i
    ; Purpose:
    ;   Prints the $name $i times
    ; Returns: nil
    (procedure (name i) do {
    	(times i do {
    		; Here is where we print
    		(print "#{name}\n")
    	})
    })

Sapphire should have a strict and enforced coding standard, a linter, a compiler, and a deployer, without having to go to any other tool to accomplish these tasks.

If a comment block is not provided at procedure definition, then the System will ask questions
and automatically generate the comment block for you. It will automatically fill out the arguments field, and allow you to edit it, as well as the returns field if that information is specified.

### Purely Functional Programming

Object Orientation is a WAY of programming, it is not BUILT IN, that's completely idiotic. Almost any programming language will allow you to produce an "Object" oriented program, including C. What most people mean when they say Object Oriented language is that it has Object Oriented Syntactic Sugar (The . Operator) and/or that it includes inheritance of some kind or another. 

Sapphire handles this simply, "Objects" are Hash Tables, if you want them to inherit some functions from another "Object", copy :)


## The Compiler

The compiler aspect is supposed to generate assembly code which can then be translated to byte
code and linked. My hope is that it will support linking to existing C Libraries.

## Typing

Right now this particular part of the system is a bit up in the air. The main idea at this point is to allow, and even encourage Type Hints (Which are enforced) otherwise during compilation a version of the procedure would be created for all possible types (leading to huge code). An example would be:

	(procedure my-proc ( number:a number:b ) returns (number) do {
		(+ a b)
	})