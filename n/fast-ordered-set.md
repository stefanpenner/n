# Set Performance

Set's are a populate data structure, often used when for checking if an entity
is a member of some set.

```js
let club = new Set();

club.has('stef'); // => false, stef isn't in the club!

club.add('stef');
club.has('stef'); // => true, stef is now in the club!

club.delete('stef');
club.has('stef'); // => true, stef is no longer in the club!
```

Although a wide range of operations are possible [As you set theory fans are
likely aware of](https://en.wikipedia.org/wiki/Set_theory), I'll just be
focusing on the most basic operations `has` `add` `delete`

