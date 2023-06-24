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

  def add_template(quiz, fields) do
    template = Template.new(fields)
    # Map.put(quiz, template.name, )
    # update_in(quiz, [template.name, fn list -> [template | list] end])
    templates =
      quiz.templates
      |> update_in([template.category], &add_template_or_nil(&1, template))

    %{quiz | templates: templates}
  end

  def add_template_or_nil(nil, template), do: [template]
  def add_template_or_nil(templates, template), do: [template | templates]

  def select_question(%__MODULE__{templates: t}) when map_size(t) == 0, do: nil

  def select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  def reset_template_cycle(%__MODULE__{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
        IO.inspect(used, label: "used")
    %__MODULE__{
      quiz
      | templates: Enum.group_by(used, fn template -> template.category end),
        used: []
    }
  end

  def reset_template_cycle(quiz), do: quiz

  def pick_current_question(%__MODULE__{templates: templates} = quiz) do
    Map.put(
      quiz,
      :current_question,
      select_random_question(templates)
    )
  end

  def select_random_question(templates) when map_size(templates) == 0, do: nil

  def select_random_question(templates) do
    # with {_category, question} <- Enum.random(templates) do
    #   Enum.random(question)
    # end
    Enum.random(templates)
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  def move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  def template(quiz), do: quiz.current_question.template

  def remove_template_from_category(quiz) do
    # find template by name and remove
    used_template = template(quiz)

    new_category =
      quiz.templates
      |> Map.fetch!(used_template.category)
      |> List.delete(used_template)

    new_templates =
      if new_category == [] do
        Map.delete(quiz.templates, used_template.category)
      else
        Map.put(quiz.templates, used_template.category, new_category)
        # put_in(map)
      end

      Map.put(quiz, :templates, new_templates)
    # %{quiz | templates: new_templates}
  end

  def add_template_to_field(quiz, field) do
    # either to :used or :mastered
    template = template(quiz)
    list = Map.get(quiz, field)
    Map.put(quiz, field, [template|list])
  end

  def answer_question(quiz, %Response{correct: true} = response) do
    new_quiz =
      quiz
      |> inc_record()
      |> save_response(response)

    maybe_advance(new_quiz, mastered?(new_quiz))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  def save_response(quiz, response) do
    Map.put(quiz, :last_response, response)
  end

  def mastered?(quiz) do
    score = Map.get(quiz.record, template(quiz).name, 0)
    score == quiz.mastery
  end

  def inc_record(%{current_question: question} = quiz) do
    new_record = Map.update(quiz.record, question.template.name, 0, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  def maybe_advance(quiz, false = _mastered), do: quiz
  def maybe_advance(quiz, true = _mastered), do: advance(quiz)

  def advance(quiz) do
    quiz
    |> move_template(:mastered)
    |> reset_record()
    |> reset_used()
  end

  def reset_record(%{current_question: question} = quiz) do
    Map.put(quiz, :record, Map.delete(quiz.record, question.template.name))
  end

  def reset_used(%{current_question: question} = quiz) do
    Map.put(quiz, :used, List.delete(quiz.used, question.template))
  end
end

# checker = fn sub, answer -> sub[:left] + sub[:right] == String.to_integer(answer) end
