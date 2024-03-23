# Linked List

Some (early) thoughts and observations about Mojo coming from a dynamically typed language

#### Unsafe Pointer

> `Pointer` Defines a Pointer struct that contains the address of a register passable type.

It has been interesting to use pointers after having last used them in the my UNISA days writing C++. I enjoy the fact that they don't come with their own special syntax and like (all?) other Mojo types are built from structs. Building the language from a few base components and avoiding special syntax feels nice and also familiar for someone that comes from a LISP background.

#### `@register_passable` decorator and the `ListNode` struct

Structs whose fields can fit in the CPU registers can/should be marked [`@register_passable`](https://docs.modular.com/mojo/manual/decorators/register-passable) which makes computation on these data more efficient as they are "closer to the compute". These structs used to have a [special syntax](https://docs.modular.com/mojo/changelog#v241-2024-02-29) for their constructors which returned an instance of `Self` (shorthand for the struct name/type), but are now constructed like all other structs with a void function passing an `inout` reference to `self` as the first argument.

#### Built in traits and lifecycle

Mojo comes with some traits defined as [part of the language](https://docs.modular.com/mojo/manual/traits#built-in-traits), they are at this time

1. AnyType
1. Boolable
1. CollectionElement
1. Copyable
1. Intable
1. KeyElement
1. Movable
1. PathLike
1. Sized
1. Stringable

Although `UnsafeLinkedList` implemented the methods from a number of these traits (in the form of dunder methods) it didn't seem to matter that I didn't declare that the struct implements the traits. When I say it didn't matter, `UnsafeLinkedList` has "implicit booleanness" without my declaring that `UnsafeLinkedList(Boolable)`, as long as it implements `fn __bool__(self) -> Bool`, i.e. it can be used directly in an `if` statement. Interestingly the LSP doesn't seem to recognise `Boolable` as a trait.

Many of the built in traits are part of the lifecycle of a struct. It has been interesting to learn the basics of memory management in Mojo after not having had to think of such things for the longest time. Still, I can't imagine having to go through all this boilerplate every time I create a struct, luckily Mojo creates defaults in most cases.

In general, the cognitive overhead of thinking about and manipulating types must come at the cost of being able to simultaneously reason about higher level abstractions (thinking at the system level). While types are fun I think prototyping a new idea in a dynamically typed fashion first will be the way to go.

#### Implementing an iterator

Another thing I haven't thought about much since C++ are iterators. In Clojure the idea is represented by implementing the `seqable` interface, but in Clojure, reuse of the data structures provided by the language is strongly encouraged, to the point that I have only once implemented `seqable` for a custom data type.

In order to understand how to do this in Mojo I looked to the Python (which is also new to me) documentation. It required the implementation of the following dunder methods

1. `__init__`
1. `__iter__`
1. `__next__`

Except there is a difference in Mojo as compared to Python [here](https://medium.com/@gautam.e/a-mojo-iterator-5ebd4ad6c02b). In Python you raise a `StopIteration` exception when you get to the end of the collection, while in Mojo your iterator needs to implement `__len__`. When the "length of the iterator" reaches zero is when the iteration stops.

#### Raises vs Optional

I have been interested in understanding the [discussion](https://jessewarden.com/2021/04/errors-as-values.html) around the "errors as values" for a while. I guess in Mojo the way to achieve this is to use the `Option` type as your return type - where you may have otherwise raised/thrown an exception. This forces the calling code to deal explicitly with the possibility that a function may not have returned anything useful (null return or possibly suffered a runtime error).

I haven't reached any conclusions on this...
