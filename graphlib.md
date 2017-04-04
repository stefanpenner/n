<h1 id="reinvestment-reinventing-pt-1-">Reinvestment &gt; Reinventing (pt.1)</h1>
<p>I&#39;ve found myself writing custom adhoc graph helpers/functions/libs for various
projects, but really that doesn&#39;t make much sense. Rather then reinventing the
wheel, I&#39;ve decided to use an existing library (Graphlib) and reinvest the
energy saved back into it.</p>
<p>Some nit-picks I plan to address.</p>
<ul>
<li>heavy depedencies (all of lodash): (avoid or drop lodash)</li>
<li>older es3/es5 code style (use es6 when it makes sense)</li>
<li>the built output be bundled more efficiently (rollup or similar)</li>
<li>the library has some hotspots that could be improved (make them faster)</li>
</ul>
<p>Rather then patch bombing the maintainer, I decided to send him an email
sharing my plans and asking for his blessing. His response was positive, and as
it turns out he no longer has the cycles to maintain the library is happy for the help.</p>
<p>As this project has both existing users and prior art, I want to make do my due
deligence ensuring my efforts do not regress existing functionality. To
accomplish this I will rely on both a test suite (existing) and a benchmark
suite (missing) to.</p>
<p>Time to get started</p>
<h2 id="the-benchmarks-">The Benchmarks:</h2>
<p>Benchmarks are tricky and can often be misleading. To avoid this I have found
it useful to have a mix of micro and macro benchmarks. This allows for a more
complete picture, ensuring both actionable feedback and improved confidence in
changes that have been made.</p>
<h3 id="micro-benchmarks-unit-level-">Micro benchmarks (unit level)</h3>
<p>Scenarios focused on isolated functionality:</p>
<ul>
<li><code>new Graph</code></li>
<li><code>addNode</code></li>
<li><code>addNode + addEdge</code></li>
<li><code>eachNode</code></li>
<li><code>children</code></li>
<li>...</li>
</ul>
<h3 id="macro-benchmarks-acceptance-level-">Macro benchmarks (acceptance level)</h3>
<p>Scenarios harvested from real world use-cases:</p>
<ul>
<li>graph operations on a large tree of node_modules</li>
<li>dagre</li>
<li>nomnoml</li>
</ul>
<p><em>pro-tip: Always be sure to get your benchmarks peer reviewed!</em></p>
<h3 id="micro-benchmarks">Micro Benchmarks</h3>
<p>Very focused and targeted tests.</p>
<ul>
<li><code>new Graph()</code> how fast can we create new graphs</li>
<li><code>addNode</code> how fast can we add new nodes</li>
<li><code>addEdge</code> how fast can we add an edge between nodes</li>
</ul>
<p>For micro benchmarks, I also try to get a ride array of iterations, to ensure no unexpected cliffs occure</p>
<h3 id="macro-benchmarks">Macro Benchmarks</h3>
<p>Some real world inspired usecase. These serve as a our &quot;foot in reality&quot;,
having a set of real world scenarios insures code-changes don&#39;t break
functionality or performance constraints our users may have.</p>
<ul>
<li><code>large code-base dependency graph</code></li>
<li><code>nomnoml usage</code></li>
<li><code>heimdall output</code></li>
</ul>
<h3 id="pro-tip-">Pro Tip!</h3>
<p>When writing benchmarks, ensure the code you are iterating has test coverage.
Would want your benchmarks output to actually be invalid. Without this, you
will easily waste you (and others) time.</p>
<h2 id="getting-started">Getting started</h2>
<p><a href="">do-you-even-bench</a> is a small ergonomic wrapper around benchmark.js, to
which you pass an array of test scenarios and it handles the rest.</p>
<pre><code class="lang-js"><span class="hljs-comment">// my-benchmark.js</span>

<span class="hljs-comment">// helper to make testing a wider distribution of scenarios simpler</span>

function iterations(count) {
  <span class="hljs-keyword">return</span> function() {
    <span class="hljs-keyword">let</span> g = new Graph();
    <span class="hljs-keyword">for</span> (<span class="hljs-keyword">let</span> i = <span class="hljs-number">0</span>; i &lt; count; i++) {
      <span class="hljs-keyword">let</span> a = <span class="hljs-symbol">'node</span>:' + (<span class="hljs-number">2</span> * i);
      <span class="hljs-keyword">let</span> b = <span class="hljs-symbol">'node</span>:' + (<span class="hljs-number">2</span> * i + <span class="hljs-number">1</span>);
      g.addNode(a, {})
      g.addNode(b, {})
      g.addEdge(a+b, a, b, {})
    }
    <span class="hljs-keyword">return</span> g;
  }
}

<span class="hljs-comment">// assertions to ensure our code actually does what it should</span>

onsole.log(<span class="hljs-symbol">'running</span> assertions')
<span class="hljs-keyword">let</span> one = iterations(<span class="hljs-number">1</span>)();

assert.equal(one.size(), <span class="hljs-number">1</span>);
assert.equal(one.order(), <span class="hljs-number">2</span>);
assert.deepEqual(one.nodes(), [<span class="hljs-symbol">'node</span>:<span class="hljs-number">0</span>', <span class="hljs-symbol">'node</span>:<span class="hljs-number">1</span>']);

<span class="hljs-comment">// more assertions...</span>

<span class="hljs-comment">// actual benchmark</span>

require(<span class="hljs-symbol">'do</span>-you-even-bench')([
  { name: <span class="hljs-symbol">'addNode</span> x <span class="hljs-number">2</span>, addEdge x <span class="hljs-number">1</span>',         <span class="hljs-function"><span class="hljs-keyword">fn</span>: <span class="hljs-title">iterations</span></span>(<span class="hljs-number">1</span>) },
  { name: <span class="hljs-symbol">'addNode</span> x <span class="hljs-number">20</span>, addEdge x <span class="hljs-number">10</span>',       <span class="hljs-function"><span class="hljs-keyword">fn</span>: <span class="hljs-title">iterations</span></span>(<span class="hljs-number">10</span>) },
  { name: <span class="hljs-symbol">'addNode</span> x <span class="hljs-number">200</span>, addEdge x <span class="hljs-number">100</span>',     <span class="hljs-function"><span class="hljs-keyword">fn</span>: <span class="hljs-title">iterations</span></span>(<span class="hljs-number">100</span>) },
  { name: <span class="hljs-symbol">'addNode</span> x <span class="hljs-number">2000</span>, addEdge x <span class="hljs-number">1000</span>',   <span class="hljs-function"><span class="hljs-keyword">fn</span>: <span class="hljs-title">iterations</span></span>(<span class="hljs-number">1000</span>) },
  { name: <span class="hljs-symbol">'addNode</span> x <span class="hljs-number">20000</span>, addEdge x <span class="hljs-number">10000</span>', <span class="hljs-function"><span class="hljs-keyword">fn</span>: <span class="hljs-title">iterations</span></span>(<span class="hljs-number">10000</span>) }
])
</code></pre>
<p>Output:</p>
<pre><code>node benchmarks/add-node-and-edge.js                                                                                                                                                  (<span class="hljs-number">31</span>s <span class="hljs-number">797</span>ms)
running assertions
testing
- addNode x <span class="hljs-number">2</span>, addEdge x <span class="hljs-number">1</span>
- addNode x <span class="hljs-number">20</span>, addEdge x <span class="hljs-number">10</span>
- addNode x <span class="hljs-number">200</span>, addEdge x <span class="hljs-number">100</span>
- addNode x <span class="hljs-number">2000</span>, addEdge x <span class="hljs-number">1000</span>
- addNode x <span class="hljs-number">20000</span>, addEdge x <span class="hljs-number">10000</span>
running first test, please wait...
  addNode x <span class="hljs-number">2</span>, addEdge x <span class="hljs-number">1</span> .............. <span class="hljs-number">257</span>,<span class="hljs-number">706.88</span> op/s
  addNode x <span class="hljs-number">20</span>, addEdge x <span class="hljs-number">10</span> ............. <span class="hljs-number">23</span>,<span class="hljs-number">227.32</span> op/s
  addNode x <span class="hljs-number">200</span>, addEdge x <span class="hljs-number">100</span> ............ <span class="hljs-number">2</span>,<span class="hljs-number">456.06</span> op/s
  addNode x <span class="hljs-number">2000</span>, addEdge x <span class="hljs-number">1000</span> ............ <span class="hljs-number">171.41</span> op/s
  addNode x <span class="hljs-number">20000</span>, addEdge x <span class="hljs-number">10000</span> ............ <span class="hljs-number">8.08</span> op/s
</code></pre><h2 id="more-benchmarks">More Benchmarks</h2>
<ul>
<li>...</li>
</ul>
<h2 id="next-steps">Next Steps</h2>
<p>These benchmarks now provide confidence for the next steps refactoring and performance tuning.</p>

