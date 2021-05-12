require_relative '../automated_init'

context "Get Advisory Lock" do
  context "Build" do
    advisory_lock_pool_size_setting = 11

    get_advisory_lock = AdvisoryLock::Get.build(advisory_lock_pool_size_setting)

    advisory_lock_pool_size = get_advisory_lock.advisory_lock_pool_size

    comment advisory_lock_pool_size.inspect
    detail "Setting: #{advisory_lock_pool_size_setting.inspect}"

    test "Advisory lock pool size" do
      assert(advisory_lock_pool_size == advisory_lock_pool_size_setting)
    end
  end
end
