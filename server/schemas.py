from enum import Enum
from typing import Any

from pydantic import BaseModel
from surya.recognition.languages import CODE_TO_LANGUAGE

LANGUAGES = list(CODE_TO_LANGUAGE.keys()) + list(CODE_TO_LANGUAGE.values())
LANGUAGES = {str(lang).upper(): str(lang) for lang in sorted(set(LANGUAGES))}

Languages = Enum("Language", LANGUAGES, type=str)


class OutputFormat(str, Enum):
    markdown = "markdown"
    json = "json"
    html = "html"


class ParseResponse(BaseModel):
    format: OutputFormat
    output: str
    images: dict[str, str]
    metadata: dict[str, Any]
    success: bool
