require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Group" do
      context "Member Assignment" do
        group_size = 2
        count = 11

        batch_1, batch_2 = Controls::ID::Sequence::Group.example(count: count, size: group_size)

        group_members_1 = batch_1.map do |id|
          Hash64.get_unsigned(id) % group_size
        end

        group_members_2 = batch_2.map do |id|
          Hash64.get_unsigned(id) % group_size
        end

        context "First Batch of IDs" do
          detail "Group Members: #{group_members_1.join(', ')}"

          same_group_members = group_members_1.uniq.count == 1

          test "Group members are all the same" do
            assert(same_group_members)
          end
        end

        context "Second Batch of IDs" do
          detail "Group Members: #{group_members_2.join(', ')}"

          same_group_members = group_members_2.uniq.count == 1

          test "Group members are all the same" do
            assert(same_group_members)
          end
        end

        test "Group members for each batch differ" do
          refute(group_members_1 == group_members_2)
        end
      end
    end
  end
end
