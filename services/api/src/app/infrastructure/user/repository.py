from sqlalchemy import Column, String
from sqlalchemy.orm import DeclarativeBase, relationship


class Base(DeclarativeBase):
    pass


class UserORM(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)
    preferred_username = Column(String, nullable=True)
    email = Column(String, nullable=True)

    messages = relationship("MessageORM", back_populates="user", cascade="all, delete-orphan")
    map_states = relationship("MapStateORM", back_populates="user", cascade="all, delete-orphan")


class UserRepository:
    def __init__(self, session):
        self.session = session

    async def get(self, user_id: str) -> UserORM | None:
        return await self.session.get(UserORM, user_id)

    async def create(self, user_id: str, preferred_username: str | None, email: str | None) -> UserORM:
        user = UserORM(id=user_id, preferred_username=preferred_username, email=email)
        self.session.add(user)
        await self.session.flush()
        return user

    async def get_or_create(self, user_id: str, preferred_username: str | None, email: str | None) -> UserORM:
        user = await self.get(user_id)
        if not user:
            user = await self.create(user_id, preferred_username, email)
        return user
