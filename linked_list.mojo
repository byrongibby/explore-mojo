from memory.unsafe import Pointer

@register_passable
struct ListNode:
    var data: Int
    var link: Pointer[ListNode]

    fn __init__(data: Int) -> Self:
        return Self{data: data, link: Pointer[ListNode].get_null()}

    fn __copyinit__(existing) -> Self:
        return Self{data: existing.data, link: existing.link}

struct LinkedListIterator:
    var current: Pointer[ListNode]

    fn __init__(inout self, list: UnorderedLinkedList):
        self.current = list.first

    fn __copyinit__(inout self, existing: Self):
        self.current = existing.current

    fn __iter__(inout self) -> LinkedListIterator:
        return self
        
    fn __len__(inout self) -> Int:
        if self.current:
          return 1
        else:
          return 0

    fn __next__(inout self) -> Int:
        var current = self.current
        self.current = self.current[0].link
        return current[0].data

struct UnorderedLinkedList:
    var size: Int
    var first: Pointer[ListNode]
    var last: Pointer[ListNode]

    fn __init__(inout self):
        self.size = 0
        self.first = Pointer[ListNode].get_null()
        self.last = Pointer[ListNode].get_null()

    fn __init__(inout self, *elements: Int):
        self.size = len(elements)
        self.first = Pointer[ListNode].get_null()
        self.last = Pointer[ListNode].get_null()
        for i in range(self.size):
            self.insert_last(elements[i])

    fn __copyinit__(inout self, existing: Self):
        self = UnorderedLinkedList()
        var iterator = LinkedListIterator(existing)
        for item in iterator:
            self.insert_last(item)

    fn __del__(owned self):
        var current = self.first
        var next = current
        while next:
          next = current[0].link
          current.free()
          current = next

    fn __iter__(inout self) -> LinkedListIterator:
        return LinkedListIterator(self)

    fn __getitem__(inout self, index: Int) raises -> Int:
        var i = index
        if i < self.size:
            var ptr = self.first
            while i > 0:
                i = i - 1
                ptr = ptr[0].link
            return ptr[0].data
        else:
            raise Error("Error indexing list: out of bounds")

    fn front(inout self) raises -> Int:
      if self.first:
          return self.first[0].data
      else:
          raise Error("Error dereferencing first node: null pointer")

    fn back(inout self) raises -> Int:
      if self.last:
          return self.last[0].data
      else:
          raise Error("Error dereferencing last node: null pointer")

    fn length(inout self) -> Int:
         return self.size

    fn insert_first(inout self, new_item: Int):
        var new_node = Pointer[ListNode].alloc(1)
        new_node[0] = ListNode(new_item)
        new_node[0].link = self.first
        self.first = new_node
        if self.last == Pointer[ListNode].get_null():
            self.last = new_node
        self.size = self.size + 1

    fn insert_last(inout self, new_item: Int):
        var new_node = Pointer[ListNode].alloc(1)
        new_node[0] = ListNode(new_item)
        if self.last != Pointer[ListNode].get_null():
            self.last[0].link = new_node 
        self.last = new_node
        if self.first == Pointer[ListNode].get_null():
            self.first = new_node
        self.size = self.size + 1

fn main():
    try:
        var x = UnorderedLinkedList()
        x.insert_first(1)
        x.insert_first(0)
        x.insert_last(2)
        x.insert_last(3)
        print("Iterator:")
        for item in x:
            print(item)

        var y = x
        print_no_newline("Front of list: ")
        print(y.front())
        print_no_newline("Back of list: ")
        print(y.back())
        print_no_newline("Length of list: ")
        print(y.length())

        var z = UnorderedLinkedList(4, 5, 6, 7)
        print("Indexing:")
        print(z[0])
        print(z[1])
        print(z[2])
        print(z[3])
#        print(x[4])
        
#        var a = UnorderedLinkedList()
#        print(a.front())

        print("Done!")
    except e:
        print_no_newline("Done, with errors: ")
        print(e.data)

