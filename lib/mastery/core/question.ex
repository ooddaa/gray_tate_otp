defmodule Mastery.Core.Question do
  defstruct ~w[asked template substitutions]a

  @type t :: %__MODULE__{
          asked: String.t(),
          template: Mastery.Core.Template.t(),
          # %{substitution: any}
          substitutions: Map
        }
end
