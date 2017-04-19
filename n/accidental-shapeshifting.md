# Accidental ShapeShifting

Ember recently transitioned to using WeakMaps (when available) to store its
`meta`. This meta is used for book keeping, such as is a given object dirty,
who is watching a given object, and a location to store other cached
information about an object.

Our hope was by moving to WeakMaps we could:

1. no longer polute objects with `__ember_meta__` property
2. avoid costly `Object.defineProperty` for non-enumerability
3. avoid "Shape Changes" associated with adding an additional property to all
   tracked objects.
4. Improve Performance

As it turns out 1, 2 have been nicely addressed. Unfortuantely performance
isn't much improved, and it seems in some scenarios it may be actualy somewhat
negative. The [complex list
benchmark](https://github.com/eviltrout/ember-performance/tree/master/benchmarks/render-complex-list)
suggests that as much as 5% of time is spent just in WeakMap land.

After Speaking with [@bmeurer](https://twitter.com/bmeurer), he shared that the
V8 team has also seen this, and they have several ideas:

Today in v8 when an object is used as a key in a collection (`Set`, `Map`,
`WeakMap`, `WeakSet`) the object still must add a property to that object to
store a unique identifier and doing so causes the objects shape to change.

Example:

```sh
d8_debug --trace-maps index.js
```
*note: d8_debug is an alias to `path/to/v8/out/x64.debug/d8` which was built via `make native debug` on v8@26bc590629*

```js
// index.js
{
  let set = new WeakSet();
  let obj = { };
  print('-- set.add(obj) --');
  set.add(foo);
}
```

Output
```sh
-- set.add(obj) --
[TraceMaps: Transition from= 0x3460b3c032d9 to= 0x3460b3c0f569 name= <hash_code_symbol> ]
```

What we are seeing is `obj` recieving a new property `<has-code-symbol>`, which
transitions `obj` into a new shape. Now code "optimized" to work with the old
`shape` of object will be invalid, and require recompile if used with the new shaped `ojb`.


`<has_code_symbol>` is the property which contains the hash code used for
Map/Set/WeakSet/WeakMap identity, and it set here:

```js
function GetHash(key) {
  var hash = GetExistingHash(key);
  if (IS_UNDEFINED(hash)) {
    hash = (MathRandom() * 0x40000000) | 0;
    if (hash === 0) hash = 1;
    SET_PRIVATE(key, hashCodeSymbol, hash); // <-- adds a property to key (our object)
  }
  return hash;
}
%SetForceInlineFlag(GetHash);
```

codez in v8:

1. https://github.com/v8/v8/blob/master/src/js/weak-collection.js#L57
2. https://github.com/v8/v8/blob/9e5a064197ca3db0ff39bcc04767494ead4aa929/src/js/collection.js#L89
3. https://github.com/v8/v8/blob/9e5a064197ca3db0ff39bcc04767494ead4aa929/src/js/collection.js#L107
4. https://github.com/v8/v8/blob/9e5a064197ca3db0ff39bcc04767494ead4aa929/src/js/collection.js#L112 <-- mutates

Although objects all do have a unique `pointer`, the pointer itself
may change do to the garbage collector moving things around.

My first thought was, what if all objects already had a private `hash`
property. Unfortunately I was informed this would result in unwanted memory
waste, as this property and value are typically unused.

Instead, the idea being proposed is more creative. Today, all objects have the following layout:

```
// TODO
type
properties <-- inlined properties/values
elements <-- either empty, or a pointer to a position backing store
```

Given that the `elements` pointer is often unused, it can serve as the `hash`
value. If it is used as a pointer, the first position in the `elements` storage
would be that `hash` value.

This would illiminate the shape changed associated with using an object as a
key in a collection such as `Map` `Set` `WeakMap` `WeakSet`, all while minizing
memory overhead.

* Issue in v8: link
* Credit to the V8 team (especially [@bmeurer](https://twitter.com/bmeurer)) for
sharing insights into V8, and continuing to work on V8 performance.

