require_relative '../../../automated_init'

context "Controls" do
  context "ID Sequence" do
    context "Partitions" do
      context "Given" do
        context "Two Partitions" do
          partitions = Controls::ID::Sequence.example(5, seed: 0x0000, partitions: 2)

          ids_1, ids_2 = partitions

          context "First Partition" do
            correct_ids = [
              '00000000-0000-4000-8000-000000000000',
              '00000000-0000-4000-8000-000000000002',
              '00000000-0000-4000-8000-000000000004'
            ]

            comment ids_1.inspect
            detail "Correct IDs: #{correct_ids.inspect}"

            test do
              assert(ids_1 == correct_ids)
            end
          end

          context "Second Partition" do
            correct_ids = [
              '00000000-0000-4000-8000-000000000001',
              '00000000-0000-4000-8000-000000000003'
            ]

            comment ids_2.inspect
            detail "Correct IDs: #{correct_ids.inspect}"

            test do
              assert(ids_2 == correct_ids)
            end
          end
        end

        context "One Partition" do
          partitions = Controls::ID::Sequence.example(2, seed: 0x0000, partitions: 1)

          ids = partitions.first

          correct_ids = [
            '00000000-0000-4000-8000-000000000000',
            '00000000-0000-4000-8000-000000000001'
          ]

          comment ids.inspect
          detail "Correct IDs: #{correct_ids.inspect}"

          test do
            assert(ids == correct_ids)
          end
        end
      end

      context "Omitted" do
        ids = Controls::ID::Sequence.example(2)

        correct_ids = ids == [
          '00000000-0000-4000-8000-000000000000',
          '00000000-0000-4000-8000-000000000001'
        ]

        comment ids.inspect
        detail "Correct IDs: #{correct_ids.inspect}"

        test "Returns a single batch of IDs" do
          assert(correct_ids)
        end
      end
    end
  end
end
