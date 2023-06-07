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

  defp select_question(%__MODULE__{templates: t}) when map_size(t) == 0, do: nil

  defp select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  defp reset_template_cycle(%__MODULE__{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
    %__MODULE__{
      quiz
      | templates: Enum.group_by(used, fn template -> template.category end),
        used: []
    }
  end

  defp reset_template_cycle(quiz), do: quiz

  defp pick_current_question(%__MODULE__{templates: templates} = quiz) do
    Map.put(
      quiz,
      :current_question,
      select_random_question(templates)
    )
  end

  defp select_random_question(templates) when map_size(templates) == 0, do: nil

  defp select_random_question(templates) do
    # with {_category, question} <- Enum.random(templates) do
    #   Enum.random(question)
    # end
    Enum.random(templates)
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  defp template(quiz), do: quiz.current_question.template

  defp remove_template_from_category(quiz) do
    # find template by name and remove
    used_template = template(quiz)

    new_category =
      quiz.templates
      |> Map.fetch!(used_template.category)
      |> List.delete(used_template)

    new_templates =
      if new_category == [] do
        Map.delete(quiz.templates[used_template.category])
      else
        Map.put(quiz.templates, used_template.category, new_category)
        # put_in(map)
      end

    %{quiz | templates: new_templates}
  end

  defp add_template_to_field(quiz, field) do
    # either to :used or :mastered
    template = template(quiz)
    list = Map.get(quiz, field)
    Map.put(quiz, field, template)
  end
end
