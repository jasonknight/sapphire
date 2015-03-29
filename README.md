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