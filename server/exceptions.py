from fastapi import HTTPException


# 403
class InvalidAuthenticationSchemeException(HTTPException):
    def __init__(self, detail: str = "Invalid authentication scheme."):
        super().__init__(status_code=403, detail=detail)


class InvalidAPIKeyException(HTTPException):
    def __init__(self, detail: str = "Invalid API key."):
        super().__init__(status_code=403, detail=detail)


# 500
class FailedToConvertPDFException(HTTPException):
    def __init__(self, detail: str = "Failed to convert PDF."):
        super().__init__(status_code=500, detail=detail)
