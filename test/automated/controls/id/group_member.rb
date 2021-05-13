require_relative '../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Group Member" do
      group_size = 3

      category = Controls::StreamName::Category.random

      group_members = {}

      ids = 5.times.map do |increment|
        id = Controls::ID::GroupMember.example(increment, group_size: group_size)

        group_member = Hash64.get_unsigned(id) % group_size

        group_members[id] = group_member

        seed = id.split('-').fetch(1).to_i(16)

        comment "ID: #{increment} (Group Member: #{group_member}, Seed: #{seed}, ID: #{id.inspect})" 

        id
      end

      ids.each.with_index do |id, increment|
        group_member = group_members[id]

        context "ID: #{increment}" do
          context "IDs Belonging To Same Group Member" do
            ids.each.with_index do |compare_id, compare_id_increment|
              next if compare_id_increment == increment

              same_group_members = (compare_id_increment % group_size) == (increment % group_size)
              if not same_group_members
                next
              end

              compare_group_member = group_members[compare_id]

              context "Compare ID: #{compare_id_increment}" do
                test do
                  assert(compare_group_member == group_member)
                end
              end
            end
          end

          context "IDs Belonging To Different Group Member" do
            ids.each.with_index do |compare_id, compare_id_increment|
              next if compare_id_increment == increment

              same_group_members = (compare_id_increment % group_size) == (increment % group_size)
              if same_group_members
                next
              end

              compare_group_member = group_members[compare_id]

              context "Compare ID: #{compare_id_increment}" do
                test do
                  refute(compare_group_member == group_member)
                end
              end
            end
          end
        end
      end
    end
  end
end
