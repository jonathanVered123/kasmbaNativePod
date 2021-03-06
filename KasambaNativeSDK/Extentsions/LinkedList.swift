// Downloaded from https://github.com/raywenderlich/swift-algorithm-club/tree/master/Linked%20List

public final class LinkedList<T> {

    public class LinkedListNode<T> {
        
        var value: T
        var next: LinkedListNode?
        weak var previous: LinkedListNode?

        public init(value: T) {
            self.value = value
        }
    }

    public typealias Node = LinkedListNode<T>

    fileprivate var head: Node?

    public init() {}
    
    deinit {
        removeAll()
    }

    public var isEmpty: Bool {
        return head == nil
    }

    public var first: Node? {
        return head
    }

    public var last: Node? {
        guard var node = head else {
            return nil
        }
        
        while let next = node.next {
            node = next
        }
        return node
    }

    public var count: Int {
        guard var node = head else {
            return 0
        }
        
        var count = 1
        while let next = node.next {
            node = next
            count += 1
        }
        return count
    }
    
    public func isDetached(_ node: Node) -> Bool {
        return node.previous == nil && node.next == nil && !(head === node)
    }
    
    public func node(at index: Int) -> Node {
        assert(head != nil, "List is empty")
        assert(index >= 0, "index must be greater than 0")
        if index == 0 {
            return head!
        } else {
            var node = head!.next
            for _ in 1..<index {
                node = node?.next
                if node == nil {
                    break
                }
            }
            
            assert(node != nil, "index is out of bounds.")
            return node!
        }
    }

    public subscript(index: Int) -> T {
        let node = self.node(at: index)
        return node.value
    }

    public func append(_ value: T) {
        let newNode = Node(value: value)
        self.append(newNode)
    }

    public func append(_ node: Node) {
        let newNode = node
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }

    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        while let node = nodeToCopy {
            self.append(node.value)
            nodeToCopy = node.next
        }
    }

    public func insert(_ value: T, at index: Int) {
        let newNode = Node(value: value)
        self.insert(newNode, at: index)
    }

    public func insert(_ newNode: Node, at index: Int) {
        if index == 0 {
            newNode.next = head
            head?.previous = newNode
            head = newNode
        } else {
            let prev = node(at: index-1)
            let next = prev.next
            newNode.previous = prev
            newNode.next = next
            next?.previous = newNode
            prev.next = newNode
        }
    }
    
    public func insert(_ list: LinkedList, at index: Int) {
        if list.isEmpty { return }
        
        if index == 0 {
            list.last?.next = head
            head = list.head
        } else {
            let prev = self.node(at: index-1)
            let next = prev.next
            
            prev.next = list.head
            list.head?.previous = prev
            
            list.last?.next = next
            next?.previous = list.last?.next
        }
    }
    
    public func removeAll() {
        
        var node: Node! = head
        
        head = nil
        
        while node != nil {
            
            let next = node.next
            
            node.previous = nil
            node.next = nil
            
            node = next
        }
        
        head = nil
    }

    @discardableResult public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev

        node.previous = nil
        node.next = nil
        return node.value
    }

    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }

    @discardableResult public func remove(at index: Int) -> T {
        let node = self.node(at: index)
        return remove(node: node)
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

extension LinkedList {
    public func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
}

extension LinkedList {
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        var node = head
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        return result
    }

    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        var node = head
        while node != nil {
            if predicate(node!.value) {
                result.append(node!.value)
            }
            node = node!.next
        }
        return result
    }
    
    public func search(predicate: (T) -> Bool, startFromTail: Bool = false) -> Node? {
        var node = startFromTail ? last : head
        while node != nil {
            if predicate(node!.value) {
                return node!
            }
            node = startFromTail ? node!.previous : node!.next
        }
        return nil
    }
}

extension LinkedList {
    convenience init(array: Array<T>) {
        self.init()

        for element in array {
            self.append(element)
        }
    }
}

extension LinkedList: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: T...) {
    self.init()

    for element in elements {
      self.append(element)
    }
  }
}
