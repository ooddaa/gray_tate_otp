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
end
