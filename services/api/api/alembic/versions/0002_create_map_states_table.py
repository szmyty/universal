"""create map_states table"""

from alembic import op
import sqlalchemy as sa

from services.api.constants import (
    MAP_STATES_TABLE,
    USERS_TABLE,
    REVISION_CREATE_MAP_STATES_TABLE,
    REVISION_CREATE_MESSAGES_TABLE,
)

revision = REVISION_CREATE_MAP_STATES_TABLE
down_revision = REVISION_CREATE_MESSAGES_TABLE
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create the ``map_states`` table."""
    op.create_table(
        MAP_STATES_TABLE,
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey(f"{USERS_TABLE}.id"), nullable=False),
        sa.Column("state", sa.JSON(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )



def downgrade() -> None:
    """Drop the ``map_states`` table."""
    op.drop_table(MAP_STATES_TABLE)
