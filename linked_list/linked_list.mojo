from memory.unsafe import Pointer
from collections.optional import Optional
from testing import *

@register_passable
struct ListNode:
    var data: Int
    var link: Pointer[ListNode]

    fn __init__(inout self, data: Int):
        self.data = data
        self.link = Pointer[ListNode].get_null()
        
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data
        self.link = existing.link

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

struct UnsafeLinkedList(Boolable, CollectionElement, Sized, Stringable): 
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
        var string = String("[")
        if current:
            string += String(current[0].data) 
            while current[0].link:
                current = current[0].link
                string +=  ", " + String(current[0].data) 
        string += "]"
        return string

    fn __contains__(borrowed self, search_item: Int) -> Bool:
        var iterator = LinkedListIterator(self)
        for item in iterator:
            if item == search_item:
                return True
        return False
        
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

    fn delete_node(inout self, delete_item: Int):
        var current = self.first
        var next = current
        var prev = current
        while current:
            if current[0].data == delete_item:
                if (current == self.first) & (current == self.last):
                    self.first = Pointer[ListNode].get_null()
                    self.last = Pointer[ListNode].get_null()
                    current.free()
                  elif current == self.first:
                    self.first = current[0].link
                    current.free()
                  elif current == self.last:
                    self.last = prev
                    prev[0].link = Pointer[ListNode].get_null()
                    current.free()
                  else:
                    prev[0].link = next
                    current.free()
                break
            prev = current
            current = next
            next = current[0].link

fn main():
    try:
        print("Test: Singly linked list implemented with unsafe pointer")
        # Test implicit booleanness
        var x = UnsafeLinkedList()
        assert_equal("List is not empty" if x else "List is empty", "List is empty")
        # Test insert first and last
        x.insert_first(1)
        x.insert_first(0)
        x.insert_last(2)
        x.insert_last(3)
        assert_equal(x.__str__(), "[0, 1, 2, 3]")
        # Test contains
        assert_false(5 in x)
        assert_true(2 in x)
        # Test copy constructor (NOTE: not a good test!)
        var y = x
        assert_equal(y.__str__(), x.__str__())
        # Test front accessor
        assert_equal(y.front().value() if y.front() else -1, 0)
        # Test back accessor
        assert_equal(y.back().or_else(-1).value(), 3)
        # Test length
        assert_equal(len(y), 4)
        # Test that node is (correctly) deleted
        y.delete_node(1)
        assert_false(1 in y)
        assert_equal(y.__str__(), "[0, 2, 3]")
        # Test iterator and indexing return the same values
        var z = UnsafeLinkedList(4, 5, 6, 7)
        var i = 0
        for item in z:
            assert_equal(item, z[i])
            i += 1
        # Test stringify
        assert_equal(z.__str__(), "[4, 5, 6, 7]")
        # Test accessing front of empty list
        var a = UnsafeLinkedList()
        assert_equal(a.front().or_else(0).value(), 0)
        # Test out of bounds exception
        with assert_raises(contains ="Error indexing list: out of bounds"):
          var x = z[4]
        print("Done, all tests passing!")
    except e:
        print_no_newline("Done, with errors: ")
        print(e)
