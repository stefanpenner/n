# Reinvestment > Reinventing (pt.1)

I've found myself writing custom adhoc graph helpers/functions/libs for various
projects, but really that doesn't make much sense. Rather then reinventing the
wheel, I've decided to use an existing library (Graphlib) and reinvest the
energy saved back into it.

Some nit-picks I plan to address.

* heavy depedencies (all of lodash): (avoid or drop lodash)
* older es3/es5 code style (use es6 when it makes sense)
* the built output be bundled more efficiently (rollup or similar)
* the library has some hotspots that could be improved (make them faster)

Rather then patch bombing the maintainer, I decided to send him an email
sharing my plans and asking for his blessing. His response was positive, and as
it turns out he no longer has the cycles to maintain the library is happy for the help.

As this project has both existing users and prior art, I want to make do my due
deligence ensuring my efforts do not regress existing functionality. To
accomplish this I will rely on both a test suite (existing) and a benchmark
suite (missing) to.

Time to get started

## The Benchmarks:

Benchmarks are tricky and can often be misleading. To avoid this I have found
it useful to have a mix of micro and macro benchmarks. This allows for a more
complete picture, ensuring both actionable feedback and improved confidence in
changes that have been made.

### Micro benchmarks (unit level)

Scenarios focused on isolated functionality:

* `new Graph`
* `addNode`
* `addNode + addEdge`
* `eachNode`
* `children`
* ...

### Macro benchmarks (acceptance level)

Scenarios harvested from real world use-cases:

* graph operations on a large tree of node_modules
* dagre
* nomnoml

*pro-tip: Always be sure to get your benchmarks peer reviewed!*

### Micro Benchmarks

Very focused and targeted tests.

* `new Graph()` how fast can we create new graphs
* `addNode` how fast can we add new nodes
* `addEdge` how fast can we add an edge between nodes

For micro benchmarks, I also try to get a ride array of iterations, to ensure no unexpected cliffs occure

### Macro Benchmarks

Some real world inspired usecase. These serve as a our "foot in reality",
having a set of real world scenarios insures code-changes don't break
functionality or performance constraints our users may have.

* `large code-base dependency graph`
* `nomnoml usage`
* `heimdall output`

### Pro Tip!

When writing benchmarks, ensure the code you are iterating has test coverage.
Would want your benchmarks output to actually be invalid. Without this, you
will easily waste you (and others) time.

## Getting started

[do-you-even-bench]() is a small ergonomic wrapper around benchmark.js, to
which you pass an array of test scenarios and it handles the rest.

```js
// my-benchmark.js

// helper to make testing a wider distribution of scenarios simpler

function iterations(count) {
  return function() {
    let g = new Graph();
    for (let i = 0; i < count; i++) {
      let a = 'node:' + (2 * i);
      let b = 'node:' + (2 * i + 1);
      g.addNode(a, {})
      g.addNode(b, {})
      g.addEdge(a+b, a, b, {})
    }
    return g;
  }
}

// assertions to ensure our code actually does what it should

onsole.log('running assertions')
let one = iterations(1)();

assert.equal(one.size(), 1);
assert.equal(one.order(), 2);
assert.deepEqual(one.nodes(), ['node:0', 'node:1']);

// more assertions...

// actual benchmark

require('do-you-even-bench')([
  { name: 'addNode x 2, addEdge x 1',         fn: iterations(1) },
  { name: 'addNode x 20, addEdge x 10',       fn: iterations(10) },
  { name: 'addNode x 200, addEdge x 100',     fn: iterations(100) },
  { name: 'addNode x 2000, addEdge x 1000',   fn: iterations(1000) },
  { name: 'addNode x 20000, addEdge x 10000', fn: iterations(10000) }
])
```

Output:

```
node benchmarks/add-node-and-edge.js                                                                                                                                                  (31s 797ms)
running assertions
testing
- addNode x 2, addEdge x 1
- addNode x 20, addEdge x 10
- addNode x 200, addEdge x 100
- addNode x 2000, addEdge x 1000
- addNode x 20000, addEdge x 10000
running first test, please wait...
  addNode x 2, addEdge x 1 .............. 257,706.88 op/s
  addNode x 20, addEdge x 10 ............. 23,227.32 op/s
  addNode x 200, addEdge x 100 ............ 2,456.06 op/s
  addNode x 2000, addEdge x 1000 ............ 171.41 op/s
  addNode x 20000, addEdge x 10000 ............ 8.08 op/s
```

## More Benchmarks

* ...

## Next Steps

These benchmarks now provide confidence for the next steps refactoring and performance tuning.
