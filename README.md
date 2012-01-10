Purpose
=======
This test harness is meant to simulate an API and serve as a test Sr::Cheddar
source.

Design
======
1. Parse a wikipedia xml file into Redis
2. Run a Sinatra server in front of Redis
3. Be as fast as possible, with configurable delay.

