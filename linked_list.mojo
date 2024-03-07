from memory.unsafe import Pointer
from collections.optional import Optional

@register_passable
struct ListNode:
    var data: Int
    var link: Pointer[ListNode]

    fn __init__(data: Int) -> Self:
        return Self{data: data, link: Pointer[ListNode].get_null()}

    fn __copyinit__(existing) -> Self:
        return Self{data: existing.data, link: existing.link}

struct LinkedListIterator(Sized):
    var current: Pointer[ListNode]

    fn __init__(inout self, list: UnsafeLinkedList):
        self.current = list.first

    fn __copyinit__(inout self, existing: Self):
        self.current = existing.current

    fn __len__(borrowed self) -> Int:
        return 1 if self.current else 0

    fn __iter__(borrowed self) -> LinkedListIterator:
        return self
        
    fn __next__(inout self) -> Int:
        var current = self.current
        self.current = self.current[0].link
        return current[0].data

struct UnsafeLinkedList(CollectionElement, Sized, Stringable): 
    var size: Int
    var first: Pointer[ListNode]
    var last: Pointer[ListNode]

    fn __init__(inout self):
        self.size = 0
        self.first = Pointer[ListNode].get_null()
        self.last = Pointer[ListNode].get_null()

    fn __init__(inout self, *elements: Int):
        self.size = 0
        self.first = Pointer[ListNode].get_null()
        self.last = Pointer[ListNode].get_null()
        for i in range(len(elements)):
            self.insert_last(elements[i])

    fn __copyinit__(inout self, existing: Self):
        self = UnsafeLinkedList()
        var iterator = LinkedListIterator(existing)
        for item in iterator:
            self.insert_last(item)

    fn __moveinit__(inout self, owned existing: Self):
        self.size = existing.size
        self.first = existing.first
        self.last = existing.last

    fn __del__(owned self):
        var current = self.first
        var next = current
        while next:
          next = current[0].link
          current.free()
          current = next

    fn __len__(borrowed self) -> Int:
         return self.size

    fn __bool__(borrowed self) -> Bool:
        return self.__len__() != 0

    fn __str__(borrowed self) -> String:
      var current = self.first
      var string = String()
      if current:
          string += "[" + String(current[0].data) 
          while current[0].link:
              current = current[0].link
              string +=  ", " + String(current[0].data) 
          string += "]"
      return string

    fn __iter__(inout self) -> LinkedListIterator:
        return LinkedListIterator(self)

    fn __getitem__(borrowed self, index: Int) raises -> Int:
        var i = index
        if i < self.size:
            var ptr = self.first
            while i > 0:
                i = i - 1
                ptr = ptr[0].link
            return ptr[0].data
        else:
            raise Error("Error indexing list: out of bounds")

    fn front(borrowed self) -> Optional[Int]:
      if self.first:
          return Optional[Int](self.first[0].data)
      else:
          return Optional[Int](None)

    fn back(borrowed self) -> Optional[Int]:
      if self.last:
          return Optional[Int](self.last[0].data)
      else:
          return Optional[Int](None)

    fn insert_first(inout self, new_item: Int):
        var new_node = Pointer[ListNode].alloc(1)
        new_node[0] = ListNode(new_item)
        new_node[0].link = self.first
        self.first = new_node
        if self.last == Pointer[ListNode].get_null():
            self.last = new_node
        self.size += 1

    fn insert_last(inout self, new_item: Int):
        var new_node = Pointer[ListNode].alloc(1)
        new_node[0] = ListNode(new_item)
        if self.last != Pointer[ListNode].get_null():
            self.last[0].link = new_node 
        self.last = new_node
        if self.first == Pointer[ListNode].get_null():
            self.first = new_node
        self.size += 1

fn main():
    try:
        print("Singly linked list implemented with unsafe pointer")
        print("")

        var x = UnsafeLinkedList()
        
        print_no_newline("Is 'x' an empty list? ")
        print("List is not empty") if x else print("List is empty")
        print("")

        x.insert_first(1)
        x.insert_first(0)
        x.insert_last(2)
        x.insert_last(3)
        print("Iterator:")
        for item in x:
            print(item)
        print("")

        let y = x
        print_no_newline("Front of list: ")
        print(y.front().value() if y.front() else 0)
        print_no_newline("Back of list: ")
        print(y.back().or_else(0).value())
        print_no_newline("Length of list: ")
        print(len(y))
        print("")

        let z = UnsafeLinkedList(4, 5, 6, 7)
        print("Indexing:")
        for i in range(len(z)):
            print(z[i])
        print("")

        print("Print the list:")
        print(z)
        print("")

        print("Get first item of empty list:")
        var a = UnsafeLinkedList()
        if not a.front():
            print("a.front() is undefined")
        print("")

#        # Get out of bounds item 
#        print(z[4])

        print("Done!")
    except e:
        print_no_newline("Done, with errors: ")
        print(e.data)
