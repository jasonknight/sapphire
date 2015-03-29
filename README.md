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
* No package managers, they are stoopid.
* Testing is part of the language

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

### No Package Managers

I know, sounds weird right? Everyone has a package manager these days, and they all suck. They suck because they are a shitty idea to begin with. When you use a language like PHP or C, you never really think: Wow, I'd like to make the process of sharing and loading code both tedious and obscure!

In Sapphire, the top of your program defines some basic information to identify it, it is the package. There are no ASDFs or separate files. You get code into your file the old fashioned way: You load it. There is no additional weird-ass package manager like Gem.

Think for a moment how stupid Gem is, it's a package manager for Ruby. Do you use Gem? No, you use Bundler. It's a Package manager for the Package Manager. How meta.

With that in mind Sapphire does come with built in support for publishing code and including open-source code in your project. You can either download the code and use something like gitmodules, or you
can push the code to the main repo if you have an account. The you can use:

	(download "jasonknight/awesome-code")

The (download) call means: check to see if I have have this file in the search path, if so, ask the server if available to give me the modified date of the code, if it's newer, download the new copy, if it's the same, just load from the disk.

If you want to lock the version, files on the server are like so: file-name-0.1.saf, so use:

(download "file-name-0.1") to lock the version. 

When you create a program, all of the code is loaded into the program under the file's namespace. There is no dependency management because all functions exist in a namespace, and all "download"ed code exists in it's subnamespace to yours.

So if your code:

	(download "user/lib1")
	(download "user2/lib2")

And user/lib2 has:

	(download "user/lib1")

Then all of the lib1 functions for user/lib2 are in: user2/lib2/user/lib1/proc-name
and all of your functions for lib1 are in main/user/lib1/proc-name, however you can omit the main/ as it is assumed.

Of course, you don't have to specify namespaces if you don't want to, or if you know that names won't conflict.

All namespaces are relative paths (what a surprise) to the current file.

Since no file that comes in with the (download) form can execute code (if it has a main function or calles it that will not be executed) dependencies matter less. If you really must establish a kind of
dependency then you can use the full path from the root of the currently executing program, i.e. /main/user/lib1/proc

### Testing is part of the language

Imagine a language where you DON'T have to install a testing suite to verify your code. Sapphire is
intended to be such a language:

	(procedure foo(string:a) returns (string) do {
		(return (+ "Hello " a))
	})
	(procedure-test foo do {
		(assert-result-includes "Hello " when "John")
		(assert-throws exception-argument when 1)
		(assert-throws my-custom-exception when 1)
	})
	(.run-test foo)

	=>
	Running tests for procedure foo
	foo assert-result-includes "Hello" PASSED when given "John"
	foo assert-throws exception-argument PASSED when given 1 
	foo assert-throws my-custom-exception FAILED when given 1
	Full Stop.
		Assertion failed, foo must throw my-custom-exception when given 1

## The Compiler

The compiler aspect is supposed to generate assembly code which can then be translated to byte
code and linked. My hope is that it will support linking to existing C Libraries.

## Typing

Right now this particular part of the system is a bit up in the air. The main idea at this point is to allow, and even encourage Type Hints (Which are enforced) otherwise during compilation a version of the procedure would be created for all possible types (leading to huge code). An example would be:

	(procedure my-proc ( number:a number:b ) returns (number) do {
		(+ a b)
	})