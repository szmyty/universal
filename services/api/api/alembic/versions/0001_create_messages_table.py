"""create users and messages tables"""

from alembic import op
import sqlalchemy as sa

from services.api.constants import (
    MESSAGES_TABLE,
    USERS_TABLE,
    REVISION_CREATE_MESSAGES_TABLE,
)

revision = REVISION_CREATE_MESSAGES_TABLE
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create the initial ``users`` and ``messages`` tables."""
    op.create_table(
        USERS_TABLE,
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("preferred_username", sa.String(), nullable=True),
        sa.Column("email", sa.String(), nullable=True),
    )

    op.create_table(
        MESSAGES_TABLE,
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("user_id", sa.String(), sa.ForeignKey(f"{USERS_TABLE}.id"), nullable=False),
        sa.Column("message", sa.Text(), nullable=False, server_default="Hello World"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )


def downgrade() -> None:
    """Drop the ``messages`` and ``users`` tables."""
    op.drop_table(MESSAGES_TABLE)
    op.drop_table(USERS_TABLE)
