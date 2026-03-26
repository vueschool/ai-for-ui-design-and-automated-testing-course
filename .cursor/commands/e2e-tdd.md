---
description: Use TDD to create new functionality 
---

1. Make a list of behaviors that you'll likely want to test
2. Write a test for each behavior
3. Run the tests (in CI mode) and observe the failure
4. Write the code to pass all the tests
5. Run the tests (in CI mode) and observe the results
6. Repeat steps 3-5 until all behaviors are tested successfully

Notes: 
* use the `data-testid` attribute to identify elements in the DOM for testing.
* use the browser mcp as needed 
