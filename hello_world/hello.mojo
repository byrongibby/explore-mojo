fn greet(name: String) -> String:
    return "Hello, " + name + "!"

trait HelloTrait:
    fn hello_string(self): ...

#struct HelloString:
#    var s: String
#
#    fn __init__(inout self, s: String):
#        self.s = s

struct HelloString(HelloTrait):
    var s: String

    fn __init__(inout self, s: String):
        self.s = s

    fn hello_string(self):
        print("Hello, ", self.s, "!")

#struct HelloString(HelloTrait):
#    fn __init__(inout self): ...
#
#    fn hello_string(self, s: String):
#        print("Hello, ", s, "!")

fn update_string(owned h: HelloString, s: String):
    h.s = s

fn main():
    var h = HelloString("world")
    #h.s = "mojo"
    #update_string(h^, "mojo")
    #print(h.s)
    #print(h.hello_string())
    var x = Tuple(1,2,3)
    print(x.get[1, Int]())

