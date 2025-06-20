from sqlalchemy import Column, Integer, Text, DateTime, func, ForeignKey, select
from sqlalchemy.orm import relationship, selectinload

from ..user.repository import Base, UserORM


class MessageORM(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(ForeignKey("users.id"), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship(UserORM, back_populates="messages")


class MessageRepository:
    def __init__(self, session):
        self.session = session

    async def create(self, user: UserORM, message: str) -> MessageORM:
        obj = MessageORM(message=message, user=user)
        self.session.add(obj)
        await self.session.commit()
        await self.session.refresh(obj)
        return obj

    async def list_all(self) -> list[MessageORM]:
        result = await self.session.execute(
            select(MessageORM).options(selectinload(MessageORM.user))
        )
        return result.scalars().all()
