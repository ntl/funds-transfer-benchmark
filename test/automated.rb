require_relative './test_init'

TestBench::Run.(
  'test/automated',
  exclude: %r{/_|sketch|(_init\.rb|_tests\.rb)\z}
)
