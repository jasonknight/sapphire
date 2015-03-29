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

The design idea behind the language is that it will be 
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
the (procedure ...) line. So the 6: means 6 lines from the call to (procedure ...).

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