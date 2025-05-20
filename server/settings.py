from functools import lru_cache
from typing import Literal, Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "INFO"
    api_key: Optional[str] = None


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
