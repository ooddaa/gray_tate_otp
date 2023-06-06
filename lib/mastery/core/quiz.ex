defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Question, Response, Template}
  # defstruct ~w[title mastery current_question last_response templates used mastered record]a
  defstruct title: nil,
            mastery: 3,
            current_question: nil,
            last_response: nil,
            # templates: %{"category" => [Mastery.Core.Template.t()]},
            templates: %{},
            used: [],
            mastered: [],
            # %{"template_name" => integer}
            record: %{}

  @type t :: %__MODULE__{
          title: String.t(),
          mastery: Integer,
          current_question: Question.t(),
          last_response: Response.t(),
          templates: Map,
          # templates: %{"category" => [Mastery.Core.Template.t()]},
          used: [Template.t()],
          mastered: [Template.t()],
          # %{"template_name" => integer}
          record: Map
        }
  def new(fields) do
    struct!(__MODULE__, fields)
  end

  defp add_template(quiz, fields) do
    template = Template.new(fields)
    # Map.put(quiz, template.name, )
    # update_in(quiz, [template.name, fn list -> [template | list] end])
    templates =
      quiz.templates
      |> update_in([template.category], &add_template_or_nil(&1, template))

    %{quiz | templates: templates}
  end

  defp add_template_or_nil(nil, template), do: [template]
  defp add_template_or_nil(templates, template), do: [template | templates]
end
