require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Group" do
      group_size = 2
      count = 5

      groups = Controls::ID::Sequence::Group.example(count: count, size: group_size)

      group_member_1_ids, group_member_2_ids = groups

      context "First Batch of IDs" do
        correct_id_sequences = [0, 2, 4]

        id_sequences = group_member_1_ids.map do |id|
          *, sequence = id.split('-')
          sequence.to_i(16)
        end

        comment id_sequences.inspect
        detail "Correct ID Sequences: #{correct_id_sequences.inspect}"

        test do
          assert(id_sequences == correct_id_sequences)
        end
      end

      context "Second Batch of IDs" do
        correct_id_sequences = [1, 3]

        id_sequences = group_member_2_ids.map do |id|
          *, sequence = id.split('-')
          sequence.to_i(16)
        end

        comment id_sequences.inspect
        detail "Correct ID Sequences: #{correct_id_sequences.inspect}"

        test do
          assert(id_sequences == correct_id_sequences)
        end
      end
    end
  end
end
