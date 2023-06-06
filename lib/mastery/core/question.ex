defmodule Mastery.Core.Question do
  defstruct ~w[asked template substitutions]a
  alias Mastery.Core.Template

  @type t :: %__MODULE__{
          asked: String.t(),
          template: Mastery.Core.Template.t(),
          # %{substitution: any}
          substitutions: Map
        }

  def new(%Template{} = template) do
    template.generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp build_substitution({name, choices_or_generator}) do
    {name, choose(choices_or_generator)}
  end

  defp choose(choices) when is_list(choices), do: Enum.random(choices)

  defp choose(generator) when is_function(generator) do
    generator.()
  end

  defp compile(template, substitutions) do
    template.compiled
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      template: template,
      substitutions: substitutions
    }
  end
end
