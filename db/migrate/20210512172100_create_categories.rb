class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
    end
    Category.create(:name => "Social", :description => "Social organisms, including humans, live collectively in interacting populations. This interaction is considered social whether they are aware of it or not, and whether the exchange is voluntary/involuntary.")
    Category.create(:name => "Eco", :description => "Relating to or concerned with the relation of living organisms to one another and to their physical surroundings.")
    Category.create(:name => "Creative", :description => "Relating to or involving the use of the imagination or original ideas to create something.")
    Category.create(:name => "Scientific", :description => "A systematic enterprise that builds and organizes knowledge in the form of testable explanations and predictions about the universe.")
  end
end
