from sqlalchemy import Column, Integer, JSON, DateTime, func, ForeignKey, select
from sqlalchemy.orm import relationship, selectinload

from ..user.repository import Base, UserORM


class MapStateORM(Base):
    __tablename__ = "map_states"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(ForeignKey("users.id"), nullable=False)
    state = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship(UserORM, back_populates="map_states")


class MapStateRepository:
    def __init__(self, session):
        self.session = session

    async def create(self, user: UserORM, state: dict) -> MapStateORM:
        obj = MapStateORM(state=state, user=user)
        self.session.add(obj)
        await self.session.commit()
        await self.session.refresh(obj)
        return obj

    async def list_all(self) -> list[MapStateORM]:
        result = await self.session.execute(
            select(MapStateORM).options(selectinload(MapStateORM.user))
        )
        return result.scalars().all()
