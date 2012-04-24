Purpose
=======
This test harness is meant to simulate an API and serve as a test
source for an sr cluster.

See [http://wiki.hyperbo.la/sr-test-cases](http://wiki.hyperbo.la/sr-test-cases)
for more information.

## Parser
The parser can parse xml dumps of wikipedia articles. It parses data into two hashes
and dumps them to disk as yaml files

```
pages[seq] = {
  id,
  title,
  num_revisions
}

revisions[seq] = {
  page_id,
  rev_id,
  fulltext,
  length
}
```

## Server endpoints

All endpoints are accessible via both GET and POST requests

* `/next_page/:seq_list`
  * `:seq_list` is a comma-separated list of page ids
  * returns a json object `{seq1 : { id, title, num_revisions }, seq2 : { ... }, ... }`
* `/next_rev/:seq_list`
  * `:seq_list` is a comma-separated list of revision ids
  * returns a json object `{seq1 : { page_id, rev_id, fulltext, length }, seq2 : { ... }, ... }`
* `/num_revs`
  * returns a json object `{ num_revs : N }` where `N` is `revisions.keys.max`

